import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  // Helper method to open manual URL

  // Helper method to clear session and log out
  Future<void> _handleLogout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Clear stored token

    if (!context.mounted) return;

    // Navigate to LoginScreen and clear backstack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('付款審批'),
      centerTitle: true,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: PopupMenuButton<String>(
        icon: const Icon(Icons.menu), // Set the hamburger icon here
        onSelected: (String value) {
          if (value == 'logout') {
            _handleLogout(context);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 12),
                Text('登出', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
