// Mock data for Organisations
// 'progress' is a value from 0.0 to 1.0 for the progress bar.
// 'isJoined' tracks the button state and must be a boolean (true/false), not a string ("true"/"false").
var organisations_data = [
  {
    "img": "https://placehold.co/100x100/A8D5BA/333333?text=EcoW",
    "name": "Eco Warriors Foundation",
    "subtitle": "Join the city-wide cleanup drive this Sunday.",
    "participants": 1204,
    "progress": 0.75,
    "isJoined": false,
  },
  {
    "img": "https://placehold.co/100x100/86B6F6/FFFFFF?text=Aqua",
    "name": "Aqua Guards",
    "subtitle": "Help us restore local lakes and rivers.",
    "participants": 856,
    "progress": 0.4,
    "isJoined": false,
  },
  {
    "img": "https://placehold.co/100x100/F6D186/FFFFFF?text=GreenP",
    "name": "Green Path",
    "subtitle": "Participate in our tree plantation initiative.",
    "participants": 2345,
    "progress": 0.9,
    "isJoined": true, // Example of an already joined event
  },
];

// Mock data for Local Events
var local_events_data = [
  {
    "img": "https://placehold.co/100x100/FFB4C2/FFFFFF?text=Art",
    "name": "Recycled Art Fair",
    "subtitle": "Exhibition of art made from recycled materials.",
    "participants": 350,
    "progress": 0.6,
    "isJoined": false,
  },
  {
    "img": "https://placehold.co/100x100/94A684/FFFFFF?text=Repair",
    "name": "Community Repair Cafe",
    "subtitle": "Bring your broken items and learn to fix them!",
    "participants": 150,
    "progress": 0.8,
    "isJoined": false,
  },
  {
    "img": "https://placehold.co/100x100/7469B6/FFFFFF?text=Swap",
    "name": "Book & Clothing Swap",
    "subtitle": "Exchange your old items for something new.",
    "participants": 540,
    "progress": 0.5,
    "isJoined": false,
  },
];

// Mock data for Charities
// 'donationProgress' is a value from 0.0 to 1.0.
var charity_data = [
  {
    "img": "https://placehold.co/100x100/51829B/FFFFFF?text=Hope",
    "name": "Foundation of Hope",
    "subtitle": "Providing clean water to remote villages.",
    "donationProgress": 0.65,
  },
  {
    "img": "https://placehold.co/100x100/D0AF84/FFFFFF?text=Shelter",
    "name": "Animal Shelter Fund",
    "subtitle": "Support our furry friends with a small donation.",
    "donationProgress": 0.8,
  },
  {
    "img": "https://placehold.co/100x100/543310/FFFFFF?text=Future",
    "name": "Green Future Initiative",
    "subtitle": "Funding research into sustainable technologies.",
    "donationProgress": 0.3,
  },
];
