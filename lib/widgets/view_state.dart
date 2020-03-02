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
  SfViewStatus _viewStatus;
  bool _disposed = false;

  SfViewState({SfViewStatus viewStatus : SfViewStatus.idle}) : _viewStatus = viewStatus;
  void initData(){}
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
  void setIdle(){
    viewStatus = SfViewStatus.idle;
  }
  void setBusy(){
    viewStatus = SfViewStatus.busy;
  }
  void setEmpty(){
    viewStatus = SfViewStatus.empty;
  }
  void setError(){
    viewStatus = SfViewStatus.error;
  }
  void setUnAuthorized(){
    viewStatus = SfViewStatus.unAuthorized;
  }

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
}

abstract class SfListViewState<T> extends SfViewState {
  List<T> list = [];

  Future<List<T>> loadData(bool refresh);
  Future<void> refresh() async {
    try{
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
    }
    catch(e){
      setError();
    }
  }
  void onCompleted(List<T> data){}

  @override
  void initData() async {
    setBusy();
    await refresh();
  }
}

abstract class SfRefreshListViewState<T> extends SfListViewState<T> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;
  Future<List<T>> loadMore() async {
    try{
      var data = await loadData(false);
      if(data.isEmpty){
        refreshController.loadNoData();
      }
      else{
        onCompleted(data);
        list.addAll(data);
        if(loadNoData(data.length)){
          refreshController.loadNoData();
        }
        else{
          refreshController.loadComplete();
        }
        notifyListeners();
      }
      return data;
    }
    catch(e){
      refreshController.loadFailed();
      return null;
    }
  }
  bool loadNoData(int length) => length<20;

  @override
  Future<void> refresh() async {
    try{
      var data = await loadData(true);
      if(data.isEmpty){
        refreshController.refreshCompleted(resetFooterState: true);
        list.clear();
        setEmpty();
      }
      else{
        onCompleted(data);
        list.clear();
        list.addAll(data);
        refreshController.refreshCompleted();
        if(loadNoData(data.length)){
          refreshController.loadNoData();
        }
        else{
         refreshController.loadComplete();
        }
        setIdle();
      }
    }
    catch(e){
      refreshController.refreshFailed();
      setError();
    }
  }
  @override
  void dispose(){
    _refreshController.dispose();
    super.dispose();
  }
}