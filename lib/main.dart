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
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: OrientationBuilder(builder: (orientationContext, orientation) {
          return Container(
              padding: EdgeInsets.only(top: statusBarHeight),
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
    // return MaterialApp(
    //   home: Scaffold(
    //     body: Padding(
    //       padding: const EdgeInsets.all(20.0),
    //       child: Column(
    //         children: [
    //           const Spacer(),
    //           ValueListenableBuilder<ProgressBarState>(
    //             valueListenable: _pageManager.progressNotifier,
    //             builder: (_, value, __) {
    //               return ProgressBar(
    //                 progress: value.current,
    //                 buffered: value.buffered,
    //                 total: value.total,
    //               );
    //             },
    //           ),
    //           ValueListenableBuilder<ButtonState>(
    //             valueListenable: _pageManager.buttonNotifier,
    //             builder: (_, value, __) {
    //               switch (value) {
    //                 case ButtonState.loading:
    //                   return Container(
    //                     margin: const EdgeInsets.all(8.0),
    //                     width: 32.0,
    //                     height: 32.0,
    //                     child: const CircularProgressIndicator(),
    //                   );
    //                 case ButtonState.paused:
    //                   return IconButton(
    //                     icon: const Icon(Icons.play_arrow),
    //                     iconSize: 32.0,
    //                     onPressed: _pageManager.play,
    //                   );
    //                 case ButtonState.playing:
    //                   return IconButton(
    //                     icon: const Icon(Icons.pause),
    //                     iconSize: 32.0,
    //                     onPressed: _pageManager.pause,
    //                   );
    //               }
    //             },
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
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
                                  return const SizedBox(
                                    // height: box.maxHeight,
                                    // width: box.maxHeight,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color.fromRGBO(255, 255, 255, 0.8)),
                                    ),
                                  );
                                // return IconButton(
                                //   icon: Image.asset('assets/play_btn.png'),
                                //   iconSize: 200,
                                //   onPressed: () {},
                                // );
                                case ButtonState.paused:
                                  return IconButton(
                                    icon: Image.asset('assets/play_btn.png'),
                                    iconSize: 200,
                                    onPressed: () {
                                      _pageManager.play();
                                      _heartAnimationController.forward();
                                    },
                                  );
                                case ButtonState.playing:
                                  return IconButton(
                                    icon: Image.asset('assets/stop_btn.png'),
                                    iconSize: 200,
                                    onPressed: () {
                                      _pageManager.pause();
                                      _heartAnimationController.reset();
                                    },
                                  );
                              }
                            },
                          ),
                          // child: FloatingActionButton(
                          //   backgroundColor: Colors.transparent,
                          //   child: isLoading
                          //       ? SizedBox(
                          //           child: CircularProgressIndicator(
                          //             strokeWidth: 4,
                          //             valueColor: AlwaysStoppedAnimation<Color>(
                          //                 Color.fromRGBO(255, 255, 255, 0.8)),
                          //           ),
                          //           height: contstraints.maxHeight,
                          //           width: contstraints.maxHeight,
                          //         )
                          //       : (isPlaying
                          //           ? Image.asset('assets/stop_btn.png')
                          //           : Image.asset('assets/play_btn.png')),
                          //   onPressed: () => isLoading
                          //       ? null
                          //       : player.playOrPause(playerState),
                          // ),
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
