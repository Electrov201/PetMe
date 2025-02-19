# Data Structure Documentation

## Firestore Collections Structure

### Users Collection (`/users/{userId}`)
```json
{
  "id": "string",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string?",
  "phoneNumber": "string?",
  "createdAt": "timestamp",
  "lastActive": "timestamp",
  "role": "string (user/admin)",
  "status": "string (active/inactive/banned)"
}

// Subcollections
/users/{userId}/private/
/users/{userId}/activities/
```

### Pets Collection (`/pets/{petId}`)
```json
{
  "id": "string",
  "name": "string",
  "type": "string",
  "breed": "string",
  "age": "number",
  "gender": "string",
  "description": "string",
  "status": "string (available/adopted/fostered/underTreatment)",
  "images": ["string (Cloudinary URLs)"],
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "ownerId": "string (userId)",
  "reporterId": "string (userId)",
  "reportedAt": "timestamp",
  "updatedAt": "timestamp",
  "medicalHistory": {
    "vaccinations": ["string"],
    "conditions": ["string"],
    "treatments": ["string"]
  }
}

// Subcollections
/pets/{petId}/medical/
```

### Rescue Requests (`/rescue_requests/{requestId}`)
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "status": "string (pending/inProgress/completed/cancelled)",
  "urgency": "string (low/medium/high/critical)",
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "images": ["string (Cloudinary URLs)"],
  "reporterId": "string (userId)",
  "assignedTo": "string? (userId)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Subcollections
/rescue_requests/{requestId}/updates/
```

### Veterinary Services (`/veterinary/{vetId}`)
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "services": ["string"],
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "contactInfo": {
    "phone": "string",
    "email": "string",
    "website": "string?"
  },
  "operatingHours": {
    "monday": { "open": "string", "close": "string" },
    // ... other days
  },
  "images": ["string (Cloudinary URLs)"],
  "ownerId": "string (userId)",
  "rating": "number",
  "reviewCount": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Subcollections
/veterinary/{vetId}/appointments/
```

### Feeding Points (`/feeding_points/{pointId}`)
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "location": {
    "latitude": "number",
    "longitude": "number",
    "address": "string"
  },
  "type": "string (water/food/both)",
  "status": "string (active/inactive)",
  "images": ["string (Cloudinary URLs)"],
  "createdBy": "string (userId)",
  "lastFilled": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Subcollections
/feeding_points/{pointId}/updates/
```

### Donations (`/donations/{donationId}`)
```json
{
  "id": "string",
  "type": "string (money/supplies/other)",
  "amount": "number?",
  "items": [{
    "name": "string",
    "quantity": "number",
    "description": "string?"
  }],
  "status": "string (pending/completed/cancelled)",
  "donorId": "string (userId)",
  "recipientId": "string (userId/organizationId)",
  "images": ["string (Cloudinary URLs)"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Chats (`/chats/{chatId}`)
```json
{
  "id": "string",
  "type": "string (direct/group)",
  "participants": ["string (userId)"],
  "lastMessage": "string",
  "lastMessageTime": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Subcollections
/chats/{chatId}/messages/
```

### Media Assets (`/media/{mediaId}`)
```json
{
  "id": "string",
  "url": "string (Cloudinary URL)",
  "type": "string (image/video/document)",
  "category": "string (pet/rescue/vet/feeding/donation)",
  "relatedId": "string (related document ID)",
  "uploaderId": "string (userId)",
  "metadata": {
    "size": "number",
    "format": "string",
    "dimensions": {
      "width": "number",
      "height": "number"
    }
  },
  "createdAt": "timestamp"
}
```

## Cloudinary Structure

### Folders Organization
```
petme/
├── users/
│   └── {userId}/
│       ├── profile/
│       └── uploads/
├── pets/
│   └── {petId}/
│       ├── primary/
│       └── gallery/
├── rescue/
│   └── {requestId}/
├── veterinary/
│   └── {vetId}/
├── feeding-points/
│   └── {pointId}/
└── donations/
    └── {donationId}/
```

### Asset Naming Convention
- Format: `{category}_{id}_{timestamp}_{type}`
- Example: `pet_123_1648656000_primary.jpg`

### Image Transformations
- Thumbnails: `w_150,h_150,c_fill`
- Profile Pictures: `w_300,h_300,c_fill`
- Gallery Images: `w_800,h_600,c_fill`
- Full Size: Original dimensions

### Delivery URLs
- Base URL: `https://res.cloudinary.com/{cloud_name}/image/upload/`
- Secure URL: `https://res.cloudinary.com/{cloud_name}/image/upload/s--{signature}--/` 