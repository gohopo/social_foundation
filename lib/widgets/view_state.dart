import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

enum SfViewStatus {
  idle,
  busy,
  empty,
  error,
  unAuthorized
}

abstract class SfViewState extends ChangeNotifier {
  SfViewState({SfViewStatus viewStatus=SfViewStatus.idle}):_viewStatus=viewStatus;
  SfViewStatus _viewStatus;
  bool _disposed = false;
  dynamic _error;
  SfViewStatus get viewStatus => _viewStatus;
  set viewStatus(SfViewStatus viewStatus){
    _viewStatus = viewStatus;
    notifyListeners();
  }
  bool get isIdle => viewStatus == SfViewStatus.idle;
  bool get isBusy => viewStatus == SfViewStatus.busy;
  bool get isEmpty => viewStatus == SfViewStatus.empty;
  bool get isError => viewStatus == SfViewStatus.error;
  bool get isUnAuthorized => viewStatus == SfViewStatus.unAuthorized;
  bool get isDisposed => _disposed == true;
  dynamic get error => _error;
  bool get wantKeepAlive => false;
  Future initDataVsync(TickerProviderStateMixin vsync) => initData();
  Future initData() async {}
  @override
  void dispose(){
    _disposed = true;
    super.dispose();
  }
  void resetState(){}
  Future delayedNotifyListeners(int milliseconds) => Future.delayed(Duration(milliseconds:milliseconds),() => notifyListeners());
  void localUpdateItems<T>({List? items,required T Function(dynamic data) factory,required ValueSetter<List<T>> add}){
    items?.removeWhere((x) => x==null);
    if(items?.isNotEmpty!=true) return;
    var list = items!.map<T>((x) => !(x is T) ? factory(x) : x).toList();
    add(list);
    notifyListeners();
  }
  void localRemoveItems<T>({required List<T> items,required ValueSetter<T> remove}){
    if(items.isEmpty) return;
    items.forEach((x)=>remove.call(x));
    notifyListeners();
  }
  @override
  void notifyListeners(){
    if(!_disposed){
      super.notifyListeners();
    }
  }
  void onRefactor(SfViewState newState){}
  void setBusy(){
    viewStatus = SfViewStatus.busy;
  }
  void setEmpty(){
    viewStatus = SfViewStatus.empty;
  }
  void setError(error){
    viewStatus = SfViewStatus.error;
    _error = error;
  }
  void setIdle(){
    viewStatus = SfViewStatus.idle;
  }
  void setUnAuthorized(){
    viewStatus = SfViewStatus.unAuthorized;
  }
}

abstract class SfListViewState<T> extends SfViewState {
  List<T> list = [];
  @override
  Future initData() async {
    setBusy();
    await refresh();
  }
  Future refresh() async {
    try{
      await refreshUnsafe();
    }
    catch(e){
      setError(e);
    }
  }
  Future<List<T>> refreshUnsafe() async {
    var data = await loadData(true);
    if(data.isEmpty){
      list.clear();
      setEmpty();
    }
    else{
      onCompleted(data);
      list.clear();
      list.addAll(data);
      setIdle();
    }
    return data;
  }
  Future<List<T>> loadData(bool refresh);
  void onCompleted(List<T> data){}
}

abstract class SfRefreshListViewState<T> extends SfListViewState<T>{
  EasyRefreshController refreshController = EasyRefreshController(controlFinishRefresh:true,controlFinishLoad:true);
  @override
  void dispose(){
    refreshController.dispose();
    super.dispose();
  }
  @override
  Future refresh() async {
    try{
      var data = await refreshUnsafe();
      refreshController.finishRefresh();
      WidgetsBinding.instance.addPostFrameCallback((_){
        refreshController.finishLoad(loadNoData(data.length)?IndicatorResult.noMore:IndicatorResult.none);
      });
    }
    catch(e){
      refreshController.finishRefresh(IndicatorResult.fail);
      setError(e);
    }
  }
  Future<List<T>?> loadMore() async {
    try{
      var data = await loadMoreUnsafe();
      refreshController.finishLoad(loadNoData(data.length)?IndicatorResult.noMore:IndicatorResult.success);
      return data;
    }
    catch(e){
      refreshController.finishLoad(IndicatorResult.fail);
      return null;
    }
  }
  Future<List<T>> loadMoreUnsafe() async {
    var data = await loadData(false);
    if(data.isNotEmpty){
      onCompleted(data);
      list.addAll(data);
    }
    notifyListeners();
    return data;
  }
  bool loadNoData(int length) => length<20;
}
