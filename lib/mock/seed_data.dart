final List<Map<String, String>> usersSeedData = [
  {
    'fullName': 'John Doe',
    'email': 'john@example.com',
    'password': 'password123', // For demo only; real backend should hash passwords!
    'role': 'admin',
  },
  {
    'fullName': 'Jane Smith',
    'email': 'jane@example.com',
    'password': 'secret456',
    'role': 'traveller',
  },
  {
    'fullName': 'Bob Driver',
    'email': 'bob@bus.com',
    'password': 'drivebus',
    'role': 'bus_driver',
  },
];

// Bus stops seed data
final List<Map<String, dynamic>> busStopsSeedData = [];

// Helper to simulate file IO for bus stops
Future<void> addBusStop(Map<String, dynamic> busStop) async {
  busStopsSeedData.add(busStop);
  // Simulate file IO delay
  await Future.delayed(const Duration(milliseconds: 300));
}
