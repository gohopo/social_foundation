import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:social_foundation/services/router_manager.dart';
import 'package:social_foundation/utils/aliyun_helper.dart';
import 'package:social_foundation/utils/image_helper.dart';
import 'package:social_foundation/widgets/cached_image_provider.dart';
import 'package:social_foundation/widgets/provider_widget.dart';
import 'package:social_foundation/widgets/toast.dart';
import 'package:social_foundation/widgets/view_state.dart';

typedef SfLoadStateChanged = Widget? Function(int index,ExtendedImageState state);

class SfPhotoViewer extends StatelessWidget{
  SfPhotoViewer({
    required this.images,int? index,String? heroPrefix,this.controller,bool? canSave,
    this.loadStateChanged,this.childrenBuilder
  })
  :_index=index??0,heroPrefix=heroPrefix??'SfPhotoViewer',canSave=canSave??true;
  final List<ImageProvider> images;
  final int _index;
  final String heroPrefix;
  final ExtendedPageController? controller;
  final bool canSave;
  final SfLoadStateChanged? loadStateChanged;
  final List<Widget> Function(int index)? childrenBuilder;
  Widget build(context) => SfProvider<SfPhotoViewerVM>(
    model: SfPhotoViewerVM(this),
    builder: (context,model,__)=>buildPage(context,model)
  );
  Widget buildPage(BuildContext context,SfPhotoViewerVM model) => Scaffold(
    backgroundColor: Colors.black,
    body: buildBody(context,model)
  );
  Widget buildBody(BuildContext context,SfPhotoViewerVM model) => Stack(
    alignment: Alignment.center,
    children: [
      buildGallery(model),
      if(images.length>1) buildIndex(context,model),
      ...(childrenBuilder?.call(model.index)??[])
    ],
  );
  Widget buildGallery(SfPhotoViewerVM model) => Positioned.fill(
    child: ExtendedImageGesturePageView.builder(
      controller: model.controller,
      itemCount: images.length,
      onPageChanged: (index)=>model.onPageChanged(index),
      itemBuilder: (_,index)=>buildPhoto(model,index),
    )
  );
  Widget buildPhoto(SfPhotoViewerVM model,int index){
    Widget image = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: SfRouterManager.pop,
      onLongPress: ()=>model.onLongPress(model,index),
      onLongPressUp: ()=>model.onLongPressUp(model,index),
      child: ExtendedImage(
        image: images[index],
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (_)=>GestureConfig(
          inPageView: true, initialScale: 1.0,
          cacheGesture: false
        ),
        loadStateChanged: (state)=>loadStateChanged?.call(index,state)
      )
    );
    return index==model.index ? Hero(
      tag: '${heroPrefix}_$index',
      child: image,
    ) : image;
  }
  Widget buildIndex(BuildContext context,SfPhotoViewerVM model) => Positioned(
    top:MediaQuery.of(context).padding.top+15,width:MediaQuery.of(context).size.width,
    child: Center(
      child: Text("${model.index+1}/${images.length}",style:TextStyle(color:Colors.white,fontSize:16)),
    ),
  );
}
class SfPhotoViewerVM extends SfViewState{
  SfPhotoViewerVM(this.widget):index=widget._index,controller=widget.controller??ExtendedPageController(initialPage:widget._index);
  SfPhotoViewer widget;
  int index;
  ExtendedPageController controller;
  void onLongPress(SfPhotoViewerVM model,int index) async {
    if(!widget.canSave) return;
    var result = await GetIt.instance<SfEasyDialog>().onShowSheet(['保存到相册','取消'],clickClose:true);
    if(result != 0) return;
    try{
      var bytes = await SfImageHelper.convertProviderToBytes(widget.images[index]);
      if(bytes==null) throw '';
      var result = await SfImageHelper.saveImage(bytes,quality:100,name:'${widget.heroPrefix}_${DateTime.now().millisecondsSinceEpoch}');
      if(result['isSuccess']==false) throw result['errorMessage'];
      GetIt.instance<SfToast>().onShowText('保存成功');
    }
    catch(error){
      print(error);
      GetIt.instance<SfToast>().onShowText('保存失败');
    }
  }
  void onLongPressUp(SfPhotoViewerVM model,int index){}
  void onPageChanged(index){
    this.index = index;
    notifyListeners();
  }
}

class SfPhotoViewer2 extends StatelessWidget{
  SfPhotoViewer2({required this.imageKeys,this.index,this.heroPrefix,this.controller,this.canSave,this.thumbnailGetter,this.childrenBuilder});
  final List<String> imageKeys;
  final int? index;
  final String? heroPrefix;
  final ExtendedPageController? controller;
  final bool? canSave;
  final String Function(String)? thumbnailGetter;
  final List<Widget> Function(int index)? childrenBuilder;
  @override
  Widget build(context) => SfPhotoViewer(
    images:imageKeys.map((fileKey)=>SfCacheManager.provider(getImageUrl(fileKey))).toList(),
    index:index,heroPrefix:heroPrefix,controller:controller,canSave:canSave,
    loadStateChanged:buildLoadStateChanged,childrenBuilder:childrenBuilder,
  );
  Widget? buildLoadStateChanged(int index,ExtendedImageState state) => state.extendedImageLoadState==LoadState.completed ? null : buildThumbnail(imageKeys[index]);
  Widget buildThumbnail(String imageKey) => SfCachedImage(
    imagePath: (thumbnailGetter??getThumbnailUrl).call(imageKey),
    fit: BoxFit.fitWidth,
  );
  String? getImageDir(String imageKey) => null;
  String getImageUrl(String imageKey) => SfAliyunOss.getImageUrl(imageKey,dir:getImageDir(imageKey));
  String getThumbnailUrl(String imageKey) => SfAliyunOss.getImageUrl(imageKey,dir:getImageDir(imageKey),width:500,height:500);
}
