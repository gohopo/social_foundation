import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/utils/image_helper.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/toast.dart';
import 'package:social_foundation/widgets/view_state.dart';

typedef SfLoadStateChanged = Widget? Function(int index,ExtendedImageState state);

class SfPhotoGalleryViewer extends StatelessWidget{
  SfPhotoGalleryViewer(Map args)
  :images=args['images']??[],_index=args['index']??0,heroPrefix=args['heroPrefix']??'SfPhotoGallery',_controller=args['controller']
  ,canSave=args['canSave']??true,loadStateChanged=args['loadStateChanged'];
  final List<ImageProvider> images;
  final int _index;
  final String heroPrefix;
  final ExtendedPageController? _controller;
  final bool canSave;
  final SfLoadStateChanged? loadStateChanged;
  
  Widget buildPhotoGallery(BuildContext context,_SfPhotoGalleryViewerModel model){
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height
        ),
        child: ExtendedImageGesturePageView.builder(
          controller: model.controller,
          itemCount: images.length,
          onPageChanged: (index) => model.onPageChanged(index),
          itemBuilder: (context,index) => buildPhoto(context,model,index),
        ),
      )
    );
  }
  Widget buildPhoto(BuildContext context,_SfPhotoGalleryViewerModel model,int index){
    Widget image = GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      onLongPress: () => onLongPress(context,model,index),
      onLongPressUp: () => onLongPressUp(context,model,index),
      child: ExtendedImage(
        image: images[index],
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (_) => GestureConfig(
          inPageView: true, initialScale: 1.0,
          cacheGesture: false
        ),
        loadStateChanged: (state) => loadStateChanged?.call(index,state)
      )
    );
    return index==model.index ? Hero(
      tag: '${heroPrefix}_$index',
      child: image,
    ) : image;
  }
  void onLongPress(BuildContext context,_SfPhotoGalleryViewerModel model,int index) async {
    if(!canSave) return;
    var result = await GetIt.instance<SfEasyDialog>().onShowSheet(['保存到相册','取消'],clickClose:true);
    if(result != 0) return;
    try{
      var bytes = await SfImageHelper.convertProviderToBytes(images[index]);
      if(bytes==null) throw '';
      var result = await SfImageHelper.saveImage(bytes,quality:100,name:'${heroPrefix}_${DateTime.now().millisecondsSinceEpoch}');
      if(result['isSuccess']==false) throw result['errorMessage'];
      GetIt.instance<SfToast>().onShowText('保存成功');
    }
    catch(error){
      print(error);
      GetIt.instance<SfToast>().onShowText('保存失败');
    }
  }
  void onLongPressUp(BuildContext context,_SfPhotoGalleryViewerModel model,int index){
    
  }
  Widget buildIndex(BuildContext context,_SfPhotoGalleryViewerModel model){
    return Positioned(
      top: MediaQuery.of(context).padding.top+15,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text("${model.index+1}/${images.length}",style: TextStyle(color: Colors.white,fontSize: 16)),
      ),
    );
  }

  Widget build(_) => Scaffold(
    backgroundColor: Colors.black,
    body: SfProvider<_SfPhotoGalleryViewerModel>(
      model: _SfPhotoGalleryViewerModel(this),
      builder: (context,model,_) => Stack(
        children: <Widget>[
          buildPhotoGallery(context,model),
          if(images.length > 1) buildIndex(context,model),
        ],
      )
    )
  );
}

class _SfPhotoGalleryViewerModel extends SfViewState{
  _SfPhotoGalleryViewerModel(this.widget):index=widget._index,controller=widget._controller??ExtendedPageController(initialPage:widget._index);
  SfPhotoGalleryViewer widget;
  int index;
  ExtendedPageController controller;

  void onPageChanged(index){
    this.index = index;
    notifyListeners();
  }
}