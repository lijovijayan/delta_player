library delta_player;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DeltaPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final double videoAspectRatio;
  final EdgeInsetsGeometry padding;
  DeltaPlayer({@required this.controller, this.videoAspectRatio, this.padding});
  @override
  _DeltaPlayerState createState() => _DeltaPlayerState();
}

class _DeltaPlayerState extends State<DeltaPlayer>
    with TickerProviderStateMixin {
  VideoProgressController _videoProgressController;
  Animation<Offset> animation;
  AnimationController _animationController;
  Offset _begin = Offset(0.0, 1.0);
  Offset _end = Offset(0.0, 0.0);
  bool _showProgressbar = true;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _videoProgressController =
        new VideoProgressController(this.widget.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(this.widget.controller.value.aspectRatio);
    Timer _progressbarAnimationDelay = Timer(Duration(seconds: 0), () => {});
    return ClipRRect(
      child: Container(
        color: Colors.black,
        child: this.widget.controller.value.initialized
            ? GestureDetector(
                onTap: () => {
                  if (_showProgressbar) _progressbarAnimationDelay.cancel(),
                  _showProgressbar
                      ? _animationController.forward()
                      : _animationController.reverse(),
                  if (_showProgressbar)
                    {
                      _progressbarAnimationDelay =
                          Timer(Duration(seconds: 5), () {
                        _showProgressbar = !_showProgressbar;
                        _animationController.reverse();
                      })
                    },
                  _showProgressbar = !_showProgressbar,
                },
                child: Stack(
                  children: [
                    Container(
                      padding: this.widget.padding,
                      alignment: Alignment.center,
                      child: AspectRatio(
                          aspectRatio: this.widget.videoAspectRatio is double
                              ? this.widget.videoAspectRatio
                              : this.widget.controller.value.aspectRatio,
                          child: VideoPlayer(this.widget.controller)),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: _begin,
                          end: _end,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeIn,
                        )),
                        child: ProgressIndicatorController(
                          this.widget.controller,
                          videoController: _videoProgressController,
                        ),
                      ),
                    ),
                    VideoTapController(
                      this.widget.controller,
                      videoController: _videoProgressController,
                    ),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }
}

class VideoTapController extends StatefulWidget {
  final VideoPlayerController _controller;
  final VideoProgressController videoController;
  VideoTapController(this._controller, {this.videoController});

  @override
  _VideoTapControllerState createState() => _VideoTapControllerState();
}

class _VideoTapControllerState extends State<VideoTapController> {
  var _rightOpacity = 0.0;
  var _leftOpacity = 0.0;

  _afterAnimation() {
    setState(() {
      _rightOpacity = 0.0;
      _leftOpacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 100, bottom: 100),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: GestureDetector(
              child: Container(
                color: Colors.transparent,
                child: AnimattedArrows(
                  opacity: _leftOpacity,
                  direction: 'left',
                  afterAnimation: _afterAnimation,
                ),
              ),
              onDoubleTap: () => {
                widget.videoController.rewind(Duration(seconds: 10)),
                _leftOpacity = 0.0,
                setState(() {
                  _leftOpacity = 1.0;
                }),
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              child: Container(
                color: Colors.transparent,
                child: AnimattedArrows(
                  opacity: _rightOpacity,
                  direction: 'right',
                  afterAnimation: _afterAnimation,
                ),
              ),
              onDoubleTap: () => {
                widget.videoController.forward(Duration(seconds: 10)),
                setState(() {
                  _rightOpacity = 1.0;
                }),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressIndicatorController extends StatefulWidget {
  final VideoPlayerController _controller;
  final VideoProgressController videoController;
  ProgressIndicatorController(this._controller, {this.videoController});

  @override
  _ProgressIndicatorControllerState createState() =>
      _ProgressIndicatorControllerState();
}

class _ProgressIndicatorControllerState
    extends State<ProgressIndicatorController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: EdgeInsets.only(top: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          VideoProgressIndicator(widget._controller,
              padding: EdgeInsets.only(bottom: 5),
              colors: VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.red,
                  backgroundColor: Colors.grey),
              allowScrubbing: true),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: MaterialButton(
                  onPressed: () => {
                    widget.videoController.rewind(Duration(seconds: 10)),
                  },
                  child: Icon(
                    Icons.fast_rewind,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: MaterialButton(
                  onPressed: () => {
                    setState(() {
                      widget._controller.value.isPlaying
                          ? widget._controller.pause()
                          : widget._controller.play();
                    }),
                  },
                  child: Icon(
                    widget._controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: MaterialButton(
                  onPressed: () => {
                    widget.videoController.forward(Duration(seconds: 10)),
                  },
                  child: Icon(
                    Icons.fast_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimattedArrows extends StatefulWidget {
  final opacity;
  final String direction;
  final Function afterAnimation;
  AnimattedArrows(
      {@required this.opacity,
      @required this.direction,
      @required this.afterAnimation});
  @override
  _AnimattedArrowsState createState() => _AnimattedArrowsState(opacity);
}

class _AnimattedArrowsState extends State<AnimattedArrows> {
  _AnimattedArrowsState(this.arrow1);
  var arrow1;
  var arrow2 = 0.0;
  var arrow3 = 0.0;
  Widget get arrows {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedOpacity(
          opacity: widget.opacity,
          duration: Duration(milliseconds: 200),
          child: Icon(
            Icons.arrow_right,
            color: Colors.white,
            size: 30,
          ),
          onEnd: () => {
            setState(() {
              if (widget.opacity == 1.0) widget.afterAnimation();
              arrow2 = 1.0;
            }),
          },
        ),
        AnimatedOpacity(
          opacity: arrow2,
          duration: Duration(milliseconds: 200),
          child: Icon(
            Icons.arrow_right,
            color: Colors.white,
            size: 30,
          ),
          onEnd: () => {
            setState(() {
              if (arrow2 == 1.0) arrow2 = 0.0;
              arrow3 = 1.0;
            }),
          },
        ),
        AnimatedOpacity(
          opacity: arrow3,
          duration: Duration(milliseconds: 200),
          child: Icon(
            Icons.arrow_right,
            color: Colors.white,
            size: 30,
          ),
          onEnd: () => {
            setState(() {
              if (arrow3 == 1.0) arrow3 = 0.0;
            }),
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == 'right'
        ? arrows
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.14),
            child: arrows);
  }
}

class VideoProgressController {
  final VideoPlayerController _controller;
  VideoProgressController(this._controller);
  forward(Duration duration) async {
    Duration position = await _controller.position;
    _controller.seekTo(Duration(
        microseconds: position.inMicroseconds + duration.inMicroseconds));
  }

  rewind(Duration duration) async {
    Duration position = await _controller.position;
    _controller.seekTo(Duration(
        microseconds: position.inMicroseconds - duration.inMicroseconds));
  }
}

class ArrowDirection {
  static const left = 'left';
  static const right = 'right';
}

