# PetMe - Pet Care and Rescue App

PetMe is a comprehensive mobile application designed to connect pet lovers, facilitate pet adoption, and provide essential pet care services. Built with Flutter and Firebase, it offers a range of features to help both pets and their caregivers.

## Features

- **Pet Adoption**: Browse and list pets available for adoption
- **Rescue Requests**: Create and respond to pet rescue requests
- **Veterinary Services**: Find and connect with veterinary clinics
- **Feeding Points**: Locate and manage community feeding points for strays
- **Health Prediction**: AI-powered pet health assessment
- **Donations**: Support pets and organizations through donations
- **Chat System**: Real-time communication between users
- **Interactive Map**: Find nearby pets, vets, and feeding points

## Getting Started

### Prerequisites

- Flutter (>=3.0.0)
- Dart (>=3.0.0)
- Firebase account
- Cloudinary account
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/petme.git
cd petme
```

2. Install dependencies
```bash
flutter pub get
```

3. Create a `.env` file in the root directory with the following variables:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_UPLOAD_PRESET=your_upload_preset

OSM_TILE_LAYER_URL=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
```

4. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and place the configuration files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

5. Run the app
```bash
flutter run
```

## Architecture

The project follows a clean architecture pattern with the following structure:

- `lib/core/`: Core functionality, models, and services
  - `models/`: Data models
  - `services/`: Business logic and API services
  - `repositories/`: Data repositories
  - `providers/`: State management
- `lib/presentation/`: UI components and screens
  - `screens/`: App screens
  - `widgets/`: Reusable widgets

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Cloudinary for media management
- OpenStreetMap for mapping services
