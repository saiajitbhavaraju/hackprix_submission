import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart'; // 1. Import the Rive package
import 'package:ecosnap_1/services/snap_state_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // 2. This function now returns a RiveAnimation widget
  Widget _getPlantImage(int actions) {
    String riveFileName;
    // This logic determines which Rive file to show.
    if (actions == 0) {
      riveFileName = 'assets/plante.riv'; // A small sprout
    } else if (actions == 2) {
      riveFileName =   'assets/green.riv';
      
    } else if (actions == 4) {      riveFileName =  'assets/greentree.riv'; } else { // 3 or more actions
      // Fully grown plant
            
           riveFileName =  'assets/greentree.riv';
    }

    
    // Use RiveAnimation.asset to display your .riv files
    return RiveAnimation.asset(
      riveFileName,
      // IMPORTANT: Check your Rive file for the correct State Machine name.
      // It might be 'State Machine 1', 'Loop', 'Timeline 1', etc.
      stateMachines: const ['State Machine 1'], 
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SnapStateService>(
      builder: (context, snapService, child) {
        final int actions = snapService.ecoActionsCount;
        final int maxActions = snapService.maxEcoActions;
        final int points = actions;
        final double overallProgress = (maxActions == 0) ? 0 : (actions / maxActions);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("My Eco Profile", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green[700],
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // This part remains the same
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircularPercentIndicator(
                          radius: 60.0,
                          lineWidth: 12.0,
                          percent: overallProgress,
                          center: Text("${(overallProgress * 100).toInt()}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          progressColor: Colors.green.shade600,
                          backgroundColor: Colors.grey.shade300,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Eco Actions",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800)),
                            const SizedBox(height: 8),
                            Text("Total Score: $points pts",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text("Goal: $actions/$maxActions",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Your Plant's Growth",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // This container now holds the Rive animation
                  Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: _getPlantImage(actions),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}