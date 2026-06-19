# Service Finder - Flutter & Spring Boot

A full-stack service marketplace application that connects customers with professional service providers such as electricians, plumbers, painters, cleaners, and technicians.

This project was developed over **10 weeks** using **Flutter** for the mobile application and **Spring Boot** for the backend REST API.

---

# Project Overview

Service Finder helps users quickly find trusted professionals, request services, manage favorites, leave reviews, receive notifications, and complete the full service workflow from booking to review.

The platform supports three different roles:

* User
* Provider
* Admin

---

# Features

## Authentication & Security

* User Registration
* User Login
* JWT Authentication
* Refresh Token Support
* Logout
* Role Based Access Control

---

## User Features

* Browse Services
* Browse Service Providers
* View Provider Details
* Search Providers
* Filter Providers
* Request Services
* Select Service Date
* Select Service Time
* Select Estimated Duration
* Track Service Requests
* View Request Progress
* Add Providers To Favorites
* Remove Favorites
* Submit Reviews & Ratings
* View Notifications
* Edit Profile
* Change Password

---

## Provider Features

* Apply As Provider
* View Application Status
* Manage Provider Profile
* Upload Cover Image
* Upload Gallery Images
* Manage Provider Gallery
* Receive Customer Requests
* Accept Requests
* Reject Requests
* Start Service Jobs
* Complete Service Jobs
* View Customer Reviews
* View Availability Status
* Busy / Available Status

---

## Admin Features

* Admin Dashboard
* Manage Services
* Create Services
* Edit Services
* Delete Services
* Review Provider Applications
* Approve Applications
* Reject Applications

---

## Reviews & Ratings

* Create Reviews
* Update Reviews
* Delete Reviews
* Average Rating Calculation
* One Review Per User Per Provider

---

## Favorites System

* Add To Favorites
* Remove From Favorites
* Check Favorite Status
* View My Favorites

---

## Notifications

* Firebase Cloud Messaging (FCM)
* User Notifications
* Provider Notifications
* Notification Management

---

## Service Requests

### Customer Side

* Create Service Request
* Select Date & Time
* Select Estimated Duration
* View Request History
* Track Request Status

### Provider Side

* View Incoming Requests
* Accept Requests
* Reject Requests
* Start Service Request
* Complete Service Request

### Request Workflow

* Pending
* Accepted
* In Progress
* Completed
* Rejected

---

## Availability & Booking System

* Provider Availability Check
* Busy / Available Status
* Remaining Time Calculation
* Prevent Overlapping Bookings
* Time Slot Validation

---

## Offline Cache

* Hive Local Storage
* Services Cache
* Providers Cache
* Offline Fallback Support

---

# Technologies Used

## Frontend

* Flutter
* Dart
* Riverpod
* Dio
* Hive
* Firebase Messaging
* Flutter Secure Storage
* Flutter Map

## Backend

* Java 21
* Spring Boot
* Spring Security
* Spring Data JPA
* JWT
* MySQL
* Maven
* Lombok

## Documentation

* Swagger / OpenAPI

---

# Architecture

Frontend:

* Feature First Architecture
* Riverpod State Management
* Repository Pattern
* Clean Architecture Principles
* Local Cache Layer

Backend:

* Controller Layer
* Service Layer
* Repository Layer
* DTO Pattern
* JWT Security

---

# Project Screenshots

## Authentication

### Login Screen

![Login](screenshots/LoginScreen.png)

### Register Screen

![Register](screenshots/RegisterScreen.png)

---

## Home

### Home Screen

![Home](screenshots/HomeScreen.png)

![Home2](screenshots/HomeScreen2.png)

---

## Services

### Services Screen

![Services](screenshots/serviceScreen.png)

---

## Provider Details

### Provider Information

![Provider](screenshots/ProviderInfoScreen.png)

![Provider2](screenshots/ProviderInfoScreen2.png)

---

## Reviews & Ratings

### Reviews Screen

![Review](screenshots/ReviewandRatingScreen.png)

![Review2](screenshots/ReviewandRatingScreen2.png)

![Review3](screenshots/ReviewandRatingScreen3.png)

---

## Service Requests

### Create Request

![Request](screenshots/RequestScreen.png)

### My Requests

![My Requests](screenshots/MyRequestsScreen.png)

---

## Favorites

### My Favorites

![Favorites](screenshots/MyFacoritesScreen.png)

---

## Notifications

### Notifications Screen

![Notifications](screenshots/NotificationScreen.png)

---

## User Profile

### Profile Screen

![Profile](screenshots/ProfileScreen.png)

![Profile2](screenshots/ProfileScreen2.png)

### User Profile

![User Profile](screenshots/ProfileUserScreen.png)

![User Profile 2](screenshots/ProfileUserScreen2.png)

### Edit Profile

![Edit Profile](screenshots/EditProfileScreen.png)

---

## Provider Features

### Apply As Provider

![Apply Provider](screenshots/ApplyasProviderScreen.png)

![Apply Provider 2](screenshots/ApplyasProviderScreen2.png)

### My Provider Profile

![Provider Profile](screenshots/MyProviderProfileScreen.png)

![Provider Profile 2](screenshots/MyProviderProfileScreen2.png)

---

## Maps

### Location Services

![Map](screenshots/MapScreen.png)

![Map2](screenshots/MapScreen2.png)

---

## Admin Dashboard

### Dashboard

![Admin Dashboard](screenshots/AdminDashboard.png)

### Manage Services

![Manage Services](screenshots/AdminDashboardManageServices.png)

### Add New Service

![Add Service](screenshots/AddNewService.png)

### Admin Profile

![Admin Profile](screenshots/AdminProfile.png)

---

# Backend API Documentation

Swagger UI:

http://localhost:8080/swagger-ui/index.html

---

# Running Flutter App

```bash
flutter pub get

flutter run
```

---

# Running Spring Boot API

```bash
mvn clean install

mvn spring-boot:run
```

---

# Development Timeline

This project was designed and implemented over a period of approximately:

**10 Weeks**

During development the following modules were completed:

* Authentication System
* User Management
* Provider Management
* Admin Dashboard
* Reviews System
* Favorites System
* Notifications System
* Request Management
* Provider Applications
* Availability System
* Booking System
* Offline Cache
* Maps Integration
* Modern UI/UX Design

---

# Author

Mustafa Salah

Full Stack Developer

Flutter Developer | Spring Boot Developer
