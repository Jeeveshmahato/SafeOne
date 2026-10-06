package com.safeone.app

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import java.io.File
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.spec.MGF1ParameterSpec
import java.security.spec.X509EncodedKeySpec
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.Mac
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.OAEPParameterSpec
import javax.crypto.spec.PSource

/// Keys that live inside the phone's secure hardware (TEE or StrongBox) and
/// can never be read out, not even with root.
///
///  * The PIN binding key mixes every PIN check with a secret that only this
///    phone's chip holds. A copy of SafeOne's files is useless elsewhere: the
///    PIN can only be guessed ON this phone, one slow hardware call at a time.
///  * The recovery key unwraps the data vault, but the chip only allows it
///    for ~20 seconds after the owner proves themselves with the phone's own
///    screen lock or a strong (class 3) biometric. That is what lets a
///    forgotten SafeOne PIN be reset without losing data.
object HardwareKeys {
    private const val KEYSTORE = "AndroidKeyStore"
    private const val BINDING_ALIAS = "safeone_pin_binding_v1"
    private const val RECOVERY_ALIAS = "safeone_vault_recovery_v1"
    private const val RECOVERY_AUTH_SECONDS = 20

    class NotAuthenticated : Exception()
    class Invalidated : Exception()

    private fun keyStore(): KeyStore = KeyStore.getInstance(KEYSTORE).apply { load(null) }

    // ---- PIN binding (HMAC-SHA256, no user auth needed) ----

    fun bind(data: ByteArray): ByteArray {
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(bindingKey())
        return mac.doFinal(data)
    }

    private fun bindingKey(): SecretKey {
        (keyStore().getKey(BINDING_ALIAS, null) as? SecretKey)?.let { return it }
        fun generate(strongBox: Boolean): SecretKey {
            val spec = KeyGenParameterSpec.Builder(BINDING_ALIAS, KeyProperties.PURPOSE_SIGN)
            if (strongBox && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                spec.setIsStrongBoxBacked(true)
            }
            val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_HMAC_SHA256, KEYSTORE)
            generator.init(spec.build())
            return generator.generateKey()
        }
        return try {
            generate(strongBox = true)
        } catch (e: Exception) {
            // StrongBox is optional hardware (StrongBoxUnavailableException,
            // or a ProviderException on some phones); the TEE is next best.
            generate(strongBox = false)
        }
    }

    /// "strongbox", "tee" or "software" (where the binding key lives).
    fun bindingLevel(): String {
        return try {
            val key = bindingKey()
            val info = SecretKeyFactory.getInstance(key.algorithm, KEYSTORE)
                .getKeySpec(key, KeyInfo::class.java) as KeyInfo
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                when (info.securityLevel) {
                    KeyProperties.SECURITY_LEVEL_STRONGBOX -> "strongbox"
                    KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT -> "tee"
                    else -> "software"
                }
            } else {
                @Suppress("DEPRECATION")
                if (info.isInsideSecureHardware) "tee" else "software"
            }
        } catch (e: Exception) {
            "software"
        }
    }

    // ---- Recovery (RSA-OAEP; decrypting needs the owner's screen lock) ----

    private val oaep = OAEPParameterSpec(
        "SHA-256", "MGF1", MGF1ParameterSpec.SHA1, PSource.PSpecified.DEFAULT,
    )

    /// Creates the recovery key if the phone has a screen lock. Returns true
    /// when a usable recovery key exists.
    fun ensureRecovery(context: Context): Boolean {
        if (keyStore().containsAlias(RECOVERY_ALIAS)) return true
        val km = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (!km.isDeviceSecure) return false
        return try {
            val spec = KeyGenParameterSpec.Builder(
                RECOVERY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setKeySize(2048)
                .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA1)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_OAEP)
                .setUserAuthenticationRequired(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                spec.setUserAuthenticationParameters(
                    RECOVERY_AUTH_SECONDS,
                    KeyProperties.AUTH_DEVICE_CREDENTIAL or KeyProperties.AUTH_BIOMETRIC_STRONG,
                )
            } else {
                @Suppress("DEPRECATION")
                spec.setUserAuthenticationValidityDurationSeconds(RECOVERY_AUTH_SECONDS)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Adding a fingerprint already needs the screen lock, which
                // can reset the PIN anyway; don't silently lose the data.
                spec.setInvalidatedByBiometricEnrollment(false)
            }
            val generator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, KEYSTORE)
            generator.initialize(spec.build())
            generator.generateKeyPair()
            true
        } catch (e: Exception) {
            false
        }
    }

    /// Encrypt with the recovery PUBLIC key (no authentication needed).
    fun recoveryWrap(secret: ByteArray): ByteArray {
        val certificate = keyStore().getCertificate(RECOVERY_ALIAS)
            ?: throw IllegalStateException("no recovery key")
        // Use a software copy of the public key: the keystore's own provider
        // is strict about the OAEP MGF1 digest on older Android versions.
        val publicKey = KeyFactory.getInstance("RSA")
            .generatePublic(X509EncodedKeySpec(certificate.publicKey.encoded))
        val cipher = Cipher.getInstance("RSA/ECB/OAEPPadding")
        cipher.init(Cipher.ENCRYPT_MODE, publicKey, oaep)
        return cipher.doFinal(secret)
    }

    /// Decrypt with the recovery PRIVATE key. Only works shortly after the
    /// owner unlocked with the screen lock or a strong biometric.
    fun recoveryUnwrap(blob: ByteArray): ByteArray {
        val key = keyStore().getKey(RECOVERY_ALIAS, null) as? PrivateKey
            ?: throw Invalidated()
        try {
            val cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding")
            cipher.init(Cipher.DECRYPT_MODE, key, oaep)
            return cipher.doFinal(blob)
        } catch (e: UserNotAuthenticatedException) {
            throw NotAuthenticated()
        } catch (e: KeyPermanentlyInvalidatedException) {
            // The screen lock was removed: the key is gone for good.
            throw Invalidated()
        }
    }

    fun deleteAll() {
        val ks = keyStore()
        for (alias in listOf(BINDING_ALIAS, RECOVERY_ALIAS)) {
            try {
                ks.deleteEntry(alias)
            } catch (_: Exception) {
            }
        }
    }

    // ---- Root detection (a warning only: it can always be hidden) ----

    fun looksRooted(): Boolean {
        val paths = listOf(
            "/system/app/Superuser.apk", "/sbin/su", "/system/bin/su", "/system/xbin/su",
            "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
            "/system/bin/failsafe/su", "/data/local/su", "/su/bin/su",
            "/system/xbin/daemonsu", "/data/adb/magisk", "/sbin/.magisk",
        )
        if (paths.any { File(it).exists() }) return true
        return Build.TAGS?.contains("test-keys") == true
    }
}
