import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGalleryViewer extends StatefulWidget {
    final List<ImageProvider> images;
    final int index;
    final String heroTag;
    final PageController controller;

    PhotoGalleryViewer({Key key,@required this.images,int index,String heroTag,PageController controller}) :
      index = index ?? 0,
      heroTag = heroTag ?? '',
      controller = controller??PageController(initialPage: index),
      super(key: key);

    @override
    _PhotoGalleryViewerState createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer>{
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
            child: Container(
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
                enableRotation: true,
                onPageChanged: (index){
                  setState(() {
                    curIndex = index;
                  });
                },
              )
            ),
          ),
          Positioned(//图片index显示
            top: MediaQuery.of(context).padding.top+15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${curIndex+1}/${widget.images.length}",style: TextStyle(color: Colors.white,fontSize: 16)),
            ),
          ),
          Positioned(//右上角关闭按钮
            right: 10,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(Icons.close,size: 30,color: Colors.white,),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}