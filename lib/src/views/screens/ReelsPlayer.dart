import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:video_player/video_player.dart';
import 'package:video_reels/src/views/widgets/loadingWidget.dart';

import '../widgets/edgingWidget.dart';


class ReelsPlayer extends StatefulWidget {
  final RxList<String> urls;
  final bool? withEdging;
  final bool? animatedIcon;
  final Widget? bottomChild;
  final Widget? rightSideChild;
  final Widget? leftSideChild;
  final Widget? loadingWidget;
  final Color? iconColor;

  const ReelsPlayer({
    super.key,
    required this.urls,
    this.animatedIcon,
    this.bottomChild,
    this.leftSideChild,
    this.loadingWidget,
    this.rightSideChild,
    this.withEdging,
    this.iconColor
  });

  @override
  State<ReelsPlayer> createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> with SingleTickerProviderStateMixin {
  late PageController pageController;
  final Map<int, VideoPlayerController> controllers = {};
  int currentIndex = 0;
  late AnimationController iconController;
  List<String> get videoUrls => widget.urls;

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    if (videoUrls.isNotEmpty) {
      _initializeVideo(0);
      _preloadNearbyVideos(1);
      _preloadNearbyVideos(2);
    }
    iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    widget.urls.listen((urls) {
      setState(() {});
      if (urls.length > controllers.length) {
        _preloadNearbyVideos(controllers.length);
      }
    });
  }

  void _initializeVideo(int index) {
    if (index >= videoUrls.length || controllers.containsKey(index)) return;

    final controller = VideoPlayerController.network(videoUrls[index]);
    controllers[index] = controller;

    controller.initialize().then((_) {
      setState(() {});
      if (index == currentIndex) controller.play();
    });

    controller.setLooping(true);
  }

  void _preloadNearbyVideos(int index) {
    for (int i = index; i <= index + 2 && i < videoUrls.length; i++) {
      _initializeVideo(i);
    }

    if (index - 1 >= 0) {
      _initializeVideo(index - 1);
    }
  }

  void _disposeFarVideos(int index) {
    final keysToKeep = [index - 1, index, index + 1, index + 2];
    final keysToRemove = controllers.keys.where((i) => !keysToKeep.contains(i)).toList();

    for (var i in keysToRemove) {
      controllers[i]?.dispose();
      controllers.remove(i);
    }
  }

  void _togglePlay(int index) {
    final controller = controllers[index];
    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
      iconController.reverse();
    } else {
      controller.play();
      iconController.forward();
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    iconController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });

          controllers[index]?.play();
          controllers.forEach((i, c) {
            if (i != index) c.pause();
          });

          _preloadNearbyVideos(index + 1);
          _preloadNearbyVideos(index + 2);
          _disposeFarVideos(index);

          if (index >= videoUrls.length - 2) {
          }
        },
        itemBuilder: (context, index) {
          final controller = controllers[index];
          return Stack(
            children: [
              (controller == null || !controller.value.isInitialized) ?
              LoadingWidget(child: widget.loadingWidget,)
                  : Positioned.fill(
                child: GestureDetector(
                  onTap: () => _togglePlay(index),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),

              if(widget.withEdging ?? false)
                const EdgingWidget(),

              if(widget.rightSideChild != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: IgnorePointer(
                    child: widget.rightSideChild,
                  ),
                ),

              if(widget.leftSideChild != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: IgnorePointer(
                    child: widget.leftSideChild,
                  ),
                ),

              if(widget.bottomChild != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: IgnorePointer(
                    child: widget.bottomChild,
                  ),
                ),

              if(widget.animatedIcon ?? false)
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 50.0,
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: iconController,
                      color: widget.iconColor ?? Colors.white,
                    ),
                    onPressed: () => _togglePlay(index),
                  ),
                )

            ],
          );

        },
      ),
    );
  }
}

