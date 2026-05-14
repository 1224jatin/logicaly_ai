import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoubtCameraScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _DoubtCameraScreen();

}
class _DoubtCameraScreen extends State<DoubtCameraScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              child: Row(
                children: const [

                  Text(
                    "Doubt-Scanner",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Camera Preview Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),

                child: Stack(
                  children: [

                    // Camera Image
                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),

                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1515879218367-8466d910aaa4",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Left Camera Icons
                    Positioned(
                      left: 10,
                      top: 20,

                      child: Column(
                        children: [

                          buildCameraIcon(Icons.flash_on),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.settings),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.grid_on),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.rotate_right),

                          const SizedBox(height: 18),

                          buildCameraIcon(Icons.timer),
                        ],
                      ),
                    ),

                    // Capture Button
                    Positioned(
                      bottom: 25,
                      left: 0,
                      right: 0,

                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 6,
                            ),
                          ),

                          child: Center(
                            child: Container(
                              width: 62,
                              height: 62,

                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------------- CAMERA ICON ----------------

  Widget buildCameraIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),

      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

}