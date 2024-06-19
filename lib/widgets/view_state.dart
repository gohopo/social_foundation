import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  @override
  void notifyListeners(){
    if(!_disposed){
      super.notifyListeners();
    }
  }
  void onRefactor(SfViewState newState){}
  void setIdle(){
    viewStatus = SfViewStatus.idle;
  }
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
  void setUnAuthorized(){
    viewStatus = SfViewStatus.unAuthorized;
  }
  //解决build中调用notifyListeners的错误
  Future delayedNotifyListeners(int milliseconds) => Future.delayed(Duration(milliseconds:milliseconds),() => notifyListeners());
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

abstract class SfRefreshListViewState<T> extends SfListViewState<T> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  RefreshController get refreshController => _refreshController;
  @override
  void dispose(){
    _refreshController.dispose();
    super.dispose();
  }
  @override
  Future refresh() async {
    try{
      var data = await refreshUnsafe();
      refreshController.refreshCompleted();
      if(loadNoData(data.length)){
        refreshController.loadNoData();
      }
      else{
        refreshController.loadComplete();
      }
    }
    catch(e){
      refreshController.refreshFailed();
      setError(e);
    }
  }
  Future<List<T>?> loadMore() async {
    try{
      var data = await loadMoreUnsafe();
      if(loadNoData(data.length)){
        refreshController.loadNoData();
      }
      else{
        refreshController.loadComplete();
      }
      return data;
    }
    catch(e){
      refreshController.loadFailed();
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