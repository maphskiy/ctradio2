import 'package:flutter/material.dart';
import 'page_manager.dart';

void main() => runApp(const MaterialApp(
    title: "Criminal Tribe Radio", home: Scaffold(body: MyApp())));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late final PageManager _pageManager;
  late final Animation _heartAnimation;
  late final AnimationController _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
    var baseSpeed = 570;
    _heartAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: baseSpeed));
    _heartAnimation = Tween(begin: 0, end: 0.01).animate(CurvedAnimation(
        curve: Curves.bounceOut, parent: _heartAnimationController));

    _heartAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _heartAnimationController.repeat();
      }
    });
  }

  Future<bool> _onWillPop() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giving up?'),
        content: const Text('Do you want to exit'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              _pageManager.pause();
              return Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  void dispose() {
    _pageManager.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pageManager.buttonNotifier.addListener(() {
      final state = _pageManager.buttonNotifier.value;
      switch (state) {
        case ButtonState.paused:
          _heartAnimationController.reset();
          break;
        case ButtonState.playing:
          _heartAnimationController.forward();
          break;
        case ButtonState.loading:
          _heartAnimationController.reset();
          break;
      }
    });

    return WillPopScope(
        onWillPop: _onWillPop,
        child: OrientationBuilder(builder: (orientationContext, orientation) {
          return Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: orientation == Orientation.portrait
                          ? BoxFit.fitHeight
                          : BoxFit.fitWidth,
                      image: const AssetImage('assets/bg_full.png'))),
              child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                        children: <Widget>[
                          SizedBox(
                            height: (constraints.maxHeight -
                                    constraints.minHeight) *
                                0.3,
                            width: constraints.maxWidth,
                            child: Container(
                                alignment: Alignment.topLeft,
                                color: Colors.transparent,
                                child: _buildHeader(orientation)),
                          ),
                          SizedBox(
                            height: (constraints.maxHeight -
                                    constraints.minHeight) *
                                0.4,
                            width: constraints.maxWidth,
                            child: Container(
                                color: Colors.transparent,
                                child: _buildPlayer()),
                          ),
                        ],
                      )));
        }));
  }

  Widget _buildPlayer() => AnimatedBuilder(
        animation: _heartAnimationController,
        builder: (context, child) {
          return Container(
              margin: EdgeInsets.all(
                  MediaQuery.of(context).size.height * _heartAnimation.value),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: AssetImage('assets/btn_bg.png'))),
              child: LayoutBuilder(
                  builder: (context, box) => Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tight(
                              Size.fromRadius(box.maxHeight * 0.225)),
                          child: ValueListenableBuilder<ButtonState>(
                            valueListenable: _pageManager.buttonNotifier,
                            builder: (_, value, __) {
                              switch (value) {
                                case ButtonState.loading:
                                  return GestureDetector(
                                    onTap: () => _pageManager.stop(),
                                    child: const SizedBox(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        valueColor: AlwaysStoppedAnimation<
                                                Color>(
                                            Color.fromRGBO(255, 255, 255, 0.8)),
                                      ),
                                    ),
                                  );
                                case ButtonState.paused:
                                  return IconButton(
                                    icon: Image.asset('assets/play_btn.png'),
                                    onPressed: () {
                                      _pageManager.play();
                                    },
                                  );
                                case ButtonState.playing:
                                  return IconButton(
                                    icon: Image.asset('assets/stop_btn.png'),
                                    onPressed: () {
                                      _pageManager.pause();
                                    },
                                  );
                              }
                            },
                          ),
                        ),
                      )));
        },
      );
  Widget _buildHeader(Orientation orientation) => Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.topLeft,
                fit: orientation == Orientation.portrait
                    ? BoxFit.fitWidth
                    : BoxFit.fitHeight,
                image: const AssetImage('assets/header.png'))),
      );
}
