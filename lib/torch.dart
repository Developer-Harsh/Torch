import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torch_light/torch_light.dart';

class TorchWidget extends StatefulWidget {
  const TorchWidget({super.key});

  @override
  State<TorchWidget> createState() => _TorchWidgetState();
}

class _TorchWidgetState extends State<TorchWidget> with WidgetsBindingObserver {
  late bool isTorch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTorchState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _destroy();
    }
  }

  Future<void> _loadTorchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isTorchOn = prefs.getBool('isTorchOn') ?? false;
    setState(() {
      isTorch = isTorchOn;
    });
    if (isTorch) {
      await TorchLight.enableTorch();
    }
  }

  void _toggleFlash() async {
    try {
      if (isTorch) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        isTorch = !isTorch;
      });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTorchOn', isTorch);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _destroy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isTorchOn', false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(isTorch ? 'assets/on.png' : 'assets/off.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: SwipeButton(
              width: 270,
              height: 70,
              thumbPadding: const EdgeInsets.all(8),
              thumb: const Icon(
                Icons.chevron_right_rounded,
                size: 32,
                color: Colors.black,
              ),
              elevationThumb: 7,
              activeThumbColor: const Color(0xFFFFFFFF),
              activeTrackColor: isTorch ? const Color(0xB3000000) : const Color(0x14FFFFFF),
              child: Text(
                isTorch ? "Swipe to turn off" : "Swipe to turn on",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onSwipe: () {
                _toggleFlash();
              },
            ),
          ),
        ),
      ],
    );
  }
}
