import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SfPhotoGalleryViewer extends StatefulWidget {
    final List<ImageProvider> images;
    final int index;
    final String heroTag;
    final PageController controller;

    SfPhotoGalleryViewer({Key key,@required this.images,int index,String heroTag,PageController controller}) :
      index = index ?? 0,
      heroTag = heroTag ?? '',
      controller = controller??PageController(initialPage: index),
      super(key: key);

    @override
    _SfPhotoGalleryViewerState createState() => _SfPhotoGalleryViewerState();
}

class _SfPhotoGalleryViewerState extends State<SfPhotoGalleryViewer>{
  int curIndex = 0;

  @override
  void initState() {
      super.initState();
      curIndex = widget.index;
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: widget.images[index],
                    heroAttributes: widget.heroTag.isNotEmpty?PhotoViewHeroAttributes(tag: widget.heroTag):null,
                  );
                },
                itemCount: widget.images.length,
                backgroundDecoration: null,
                pageController: widget.controller,
                enableRotation: false,
                onPageChanged: (index){
                  setState(() {
                    curIndex = index;
                  });
                },
              )
            )
          ),
          Positioned(//图片index显示
            top: MediaQuery.of(context).padding.top+15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${curIndex+1}/${widget.images.length}",style: TextStyle(color: Colors.white,fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}