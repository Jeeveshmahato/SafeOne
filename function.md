You are a Principal Software Architect, Senior Flutter Engineer, Senior Backend Engineer, Security Engineer, Product Manager, DevOps Engineer, QA Lead, and UX Designer.

Your task is to design and build a COMPLETE production-grade Women's Safety Application called:

# Guardian Angel

This is a non-profit personal safety and emergency response platform.

The goal is NOT to claim prevention of crimes or guarantee safety.

The goal is to help users:

* Alert trusted contacts quickly
* Share live location
* Access emergency help
* Preserve evidence
* Improve travel safety
* Access support resources
* Create a trusted guardian network

Build this application exactly as a production startup would build it.

---

# Technology Stack

Frontend:

* Flutter (Latest Stable)
* Riverpod
* Dio
* GoRouter
* Flutter Secure Storage
* Freezed
* Google Maps Flutter
* Geolocator
* Firebase Messaging
* Local Notifications

Backend:

* Node.js
* Express.js
* MongoDB Atlas
* Mongoose
* JWT Authentication
* Refresh Tokens
* Socket.IO
* Helmet
* Winston
* Rate Limiting
* Express Validator

Database:

* MongoDB Atlas

Notifications:

* Firebase Cloud Messaging

Deployment:

* Railway / Render
* Environment Variables

Admin Dashboard:

* Next.js
* React
* Tailwind CSS

---

# Architecture Requirements

Use:

* Clean Architecture
* SOLID Principles
* Feature Based Architecture
* Repository Pattern
* Dependency Injection
* Error Handling
* Logging
* Production Security

Flutter Folder Structure:

lib/
core/
shared/
features/
auth/
contacts/
sos/
tracking/
journey/
guardians/
notifications/
reports/
profile/
settings/
admin/

Backend Folder Structure:

src/
config/
controllers/
models/
routes/
middleware/
services/
sockets/
validators/
utils/

---

# PHASE 1 - AUTHENTICATION

Features:

* Register
* Login
* Logout
* Forgot Password
* Change Password
* JWT Authentication
* Refresh Token
* User Profile

User Fields:

* Name
* Email
* Phone
* Password
* Profile Image
* Role

Generate:

* MongoDB Models
* APIs
* Controllers
* Validation
* Flutter Screens
* State Management
* API Integration

---

# PHASE 2 - EMERGENCY CONTACTS

Features:

* Add Contact
* Edit Contact
* Delete Contact
* List Contacts
* Set Contact Priority
* Multiple Guardians

Fields:

* Name
* Phone
* Relation

Examples:

Mother
Father
Brother
Friend
Spouse

Generate complete implementation.

---

# PHASE 3 - SOS SYSTEM

Main Home Screen:

Large Emergency SOS Button.

When activated:

* Create Incident
* Get Current GPS Location
* Start Live Tracking
* Notify Guardians
* Trigger Push Notifications
* Activate Emergency Mode
* Save Incident Timeline

Generate complete implementation.

---

# PHASE 4 - LIVE LOCATION TRACKING

Features:

* Real-time GPS Tracking
* Socket.IO Communication
* Track Every 5 Seconds
* Last Known Location
* Location History

Generate:

* Socket Server
* Flutter Integration
* Database Design

---

# PHASE 5 - GUARDIAN DASHBOARD

Trusted Guardians can view:

* Live Location
* SOS Status
* Journey Status
* Battery Percentage
* Last Updated Time
* Last Known Location

Generate:

* APIs
* UI
* Dashboard
* Realtime Tracking

---

# PHASE 6 - JOURNEY SAFETY MODE

User can start journey:

Examples:

Home → Office
Home → College
Cab Ride
Night Travel

Features:

* Destination Selection
* ETA Selection
* Journey Start
* Journey End
* Journey Monitoring

Generate complete implementation.

---

# PHASE 7 - MISSED ARRIVAL DETECTION

Features:

If user does not arrive:

* Notify Guardians
* Send Push Notifications
* Trigger Safety Check

Generate backend logic and UI.

---

# PHASE 8 - PUSH NOTIFICATIONS

Use Firebase Cloud Messaging.

Notifications:

* SOS Triggered
* Journey Started
* Journey Ended
* Route Deviation
* Contact Requests
* Guardian Alerts

Generate complete implementation.

---

# PHASE 9 - POWER BUTTON SOS

Trigger:

Press Power Button 5 Times

Result:

* Activate SOS
* Notify Guardians
* Share Location

Generate Android implementation and iOS-compatible alternatives.

---

# PHASE 10 - SHAKE TO SOS

Trigger:

Shake Device

Result:

* Activate SOS
* Start Tracking
* Notify Contacts

Generate implementation.

---

# PHASE 11 - VOLUME BUTTON SOS

Trigger:

Volume Button Pattern

Result:

* Activate Emergency Mode

Generate implementation.

---

# PHASE 12 - LOCK SCREEN SOS

Features:

* Lock Screen Widget
* Quick SOS Access

Generate implementation.

---

# PHASE 13 - OFFLINE EMERGENCY SMS

If internet unavailable:

Send SMS to all emergency contacts:

Emergency Alert
Current Location
Google Maps Link

Generate implementation.

---

# PHASE 14 - EMERGENCY CALLING

Features:

Automatically call emergency contacts sequentially:

1. Mother
2. Father
3. Friend

Until someone answers.

Generate implementation.

---

# PHASE 15 - CAB SAFETY MODE

Fields:

* Driver Name
* Cab Number
* Cab Company
* Destination

Automatically shared with guardians.

Generate implementation.

---

# PHASE 16 - NEARBY HELP FINDER

Display nearby:

* Police Stations
* Hospitals
* Pharmacies
* Petrol Pumps
* Public Transport

Use Maps APIs.

Generate implementation.

---

# PHASE 17 - AUDIO RECORDING

When SOS activates:

* Start Audio Recording
* Upload Securely

Generate architecture and implementation.

---

# PHASE 18 - VIDEO RECORDING

When SOS activates:

* Start Video Recording
* Upload Securely

Generate architecture and implementation.

---

# PHASE 19 - EVIDENCE VAULT

Store:

* Audio
* Video
* GPS Logs
* Timestamps
* Incident Timeline

Generate complete secure implementation.

---

# PHASE 20 - INCIDENT HISTORY

User can view:

* Previous SOS Events
* Previous Journeys
* Location History

Generate complete implementation.

---

# PHASE 21 - SAFETY HEATMAP

Users can report:

* Harassment
* Stalking
* Unsafe Roads
* Poor Lighting

Generate:

* Anonymous Reporting System
* Heatmap Visualization

---

# PHASE 22 - COMMUNITY SAFETY REPORTS

Features:

* Anonymous Reports
* Community Alerts
* Moderation System

Generate complete implementation.

---

# PHASE 23 - SAFE ROUTE RECOMMENDATION

Suggest:

* Well-lit Roads
* Public Areas
* Busy Routes

Avoid:

* Reported Unsafe Areas

Generate implementation.

---

# PHASE 24 - VOICE SOS

Secret phrases:

* Help Me
* Emergency
* Call My Family

Trigger SOS automatically.

Generate implementation.

---

# PHASE 25 - AI RISK DETECTION

Analyze:

* Time
* Route Deviation
* User Inactivity
* Area Risk

Generate:

* Risk Scoring Engine
* Architecture
* Backend Logic

---

# PHASE 26 - SMART ALERTS

Examples:

"You entered a low activity area."

"Would you like to share your journey?"

Generate implementation.

---

# PHASE 27 - MEDICAL PROFILE

Store:

* Blood Group
* Allergies
* Emergency Notes
* Medical Conditions

Generate implementation.

---

# PHASE 28 - ICE PROFILE

In Case of Emergency profile.

Quick access during emergencies.

Generate implementation.

---

# PHASE 29 - HELPLINE DIRECTORY

Provide quick access to:

* Police
* Ambulance
* Women Helplines
* Emergency Services

Generate implementation.

---

# PHASE 30 - LEGAL & SUPPORT RESOURCES

Provide:

* FIR Guidance
* Safety Information
* NGO Directory
* Counseling Resources

Generate implementation.

---

# PHASE 31 - ADMIN DASHBOARD

Admin Features:

* User Management
* Incident Monitoring
* Report Moderation
* Analytics

Use:

* Next.js
* React
* Tailwind

Generate complete implementation.

---

# PHASE 32 - ANALYTICS

Track:

* SOS Activations
* Active Journeys
* Community Reports
* User Engagement

Generate implementation.

---

# SECURITY REQUIREMENTS

Implement:

* JWT
* Refresh Tokens
* Bcrypt Password Hashing
* Input Validation
* Rate Limiting
* Helmet
* CORS Protection
* Secure Storage
* Audit Logging
* Environment Variables

---

# TESTING

Generate:

* Unit Tests
* Integration Tests
* API Tests
* Flutter Widget Tests

---

# DEVOPS

Generate:

* Docker Configuration
* CI/CD Pipeline
* GitHub Actions
* Railway Deployment
* MongoDB Atlas Setup

---

# CODE GENERATION RULES

Generate the application phase-by-phase.

For EACH phase provide:

1. Folder Structure
2. Database Schema
3. Backend Code
4. Flutter Code
5. APIs
6. Validation
7. Error Handling
8. Security
9. Testing
10. Deployment Notes

Never provide pseudocode.

Generate production-ready code only.

Start with Phase 1 Authentication and do not skip implementation details.
