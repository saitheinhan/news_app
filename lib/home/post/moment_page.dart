import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:news/home/page_details/moment_page_details.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:news/models/check_time.dart';
import 'package:news/home/comment_reply/comment_page.dart';
import 'package:news/models/following.dart';
import 'package:news/models/moment.dart';
import 'package:news/models/user.dart';
import 'package:news/profile/recommend_user_profile.dart';
import 'package:news/profile/user_profile_page.dart';
import 'package:news/home/post/moment_image.dart';

class MomentPage extends StatefulWidget {
  final Moment moment;
  MomentPage({Key key,this.moment});

  @override
  _MomentPageState createState() => _MomentPageState();
}

class _MomentPageState extends State<MomentPage> {

  Moment moment;
  Following following;

  var images=[
    "adv1.jpg","adv2.jpg","adv3.jpg","panda.jpg","minion.jpg",
  ];
  int totalHeight=0;
  int imgHeight=0;
  int profileHeight=50;
  int captionHeight=110;
  int likeHeight=30;
  int bottomHeight=5;
  int dividerHeight=1;
  int recommendHeight=200;
  int like=0;
  int comment=0;

  bool isFollowed=false;
  bool isExpanded=false;
  bool isLiked=false;
  bool isShowed=false;
  bool first=true;

  DateTime now= DateTime.now();
  DateTime created;
  String date="";
  String name='';
  TimeOfDay releaseTime = TimeOfDay(hour: 8, minute: 10);

  CarouselSlider carouselSlider;
  int _current = 0;
  int _count = 1;
  int _total = 0;
  List list = [
    'https://images.unsplash.com/photo-1502117859338-fd9daa518a9a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1554321586-92083ba0a115?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1536679545597-c2e5e1946495?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    /*'https://images.unsplash.com/photo-1543922596-b3bbaba80649?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1502943693086-33b5b1cfdf2f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80',
    'https://images.unsplash.com/photo-1543922596-b3bbaba80649?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1543922596-b3bbaba80649?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1502943693086-33b5b1cfdf2f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80',*/
  ];
  //List imgList=['minion.jpg','panda.jpg','adv3.jpg','adv5.jpg','adv3.jpg','adv4.jpg','adv1.jpg','minion.jpg','panda.jpg'];
  List<String> imgList=[];

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    moment=widget.moment;
    getUserInfo(moment.userID).then((value){
      setState(() {
        following=value;
        name=following.userName;
      });
    });
    var array= moment.image.split(",");
    for(int i=0;i<array.length;i++){
      imgList.add(array[i]);
    }

    var arr= moment.createDate.split('-');
    var arr1= arr[2].split(':');
    var arr2= arr1[0].split('T');
    created= DateTime(int.parse(arr[0]),int.parse(arr[1]),int.parse(arr2[0]),int.parse(arr2[1]),int.parse(arr1[1]));

    like=moment.likeCount;
    date=Check().checkDate(created, now);
    imgHeight=Check().checkImage(imgList);
    totalHeight=profileHeight+captionHeight+imgHeight+likeHeight+bottomHeight+dividerHeight;
  }

  Future<Following> getUserInfo(int id) async{
    var url="http://192.168.0.119:3000//api/user/info";
    var res=await http.post(url,
    body: {
      'Userid' : id.toString(),
    });
      var data=jsonDecode(res.body);
      Map userMap=data['data'];
      Following following=Following.fromJson(userMap);
    return following;
  }

  updateLike(int id,int count) async{
    var response= await http.put("http://192.168.0.119:3000//api/update/like",
    body: {
      'Momentpostid' : id.toString(),
      'Likecount' : count.toString(),
    });
    if(response.statusCode ==200){
      print("update success");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: totalHeight.toDouble(),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Container(
            height: profileHeight.toDouble(),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfilePage()));
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                image: DecorationImage(
                                  image: AssetImage('assets/minion.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    height: 50.0,
                    //width: MediaQuery.of(context).size.width*(90/100),
                    //padding: EdgeInsets.only(left: 8.0,right: 5.0,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProfilePage()));
                          },
                          child: Container(
                            child: Text(name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 18.0,
                          width: 120.0,
                          padding: EdgeInsets.only(top: 5.0,),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(date.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
//                Expanded(
////                  flex: 4,
////                  child: GestureDetector(
////                    onTap: (){
////                      setState(() {
////                        if(first){
////                          if(isFollowed){
////                            isShowed=false;
////                            isFollowed=false;
////                            isExpanded=false;
////                            totalHeight=totalHeight-recommendHeight;
////                          }else{
////                            isFollowed=true;
////                            isExpanded=true;
////                            isShowed=true;
////                            totalHeight=totalHeight+recommendHeight;
////                          }
////                        }else{
////                          isShowed=false;
////                          isFollowed=false;
////                          isExpanded=false;
////                          first=true;
////                          //totalHeight=totalHeight-recommendHeight;
////                        }
////
////                      });
////                    },
////                    child: Container(
////                      height: 20.0,
////                      //padding: EdgeInsets.only(right: .0),
////                      //width: MediaQuery.of(context).size.width*(10/100),
////                      child: Row(
////                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
////                        children: <Widget>[
////                          Container(
////                            height: 20.0,
////                            padding: EdgeInsets.only(left: 5.0,right: 5.0),
////                            decoration: BoxDecoration(
////                              color: isFollowed? Colors.white : Colors.blue,
////                              borderRadius: BorderRadius.circular(5.0,),
////                              border: Border.all(
////                                color: isFollowed? Colors.black12 : Colors.blue,
////                                width: 1.0
////                              ),
////                            ),
////                            child: Center(
////                              child: Row(
////                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                                children: <Widget>[
////                                  Container(
////                                    //width: 12.0,
////                                    height: 12.0,
////                                    decoration: BoxDecoration(
////                                      color: isFollowed? Colors.blue : Colors.white,
////                                      borderRadius: BorderRadius.circular(100.0),
////                                    ),
////                                    child: Icon(isFollowed? Icons.check: Icons.add,
////                                      color: isFollowed? Colors.white : Colors.blue,size: 12.0,),
////                                  ),
////                                  SizedBox(width: 5.0,),
////                                  Text('Follow',
////                                    style: TextStyle(
////                                      color: isFollowed? Colors.grey : Colors.white,
////                                      fontSize: 12.0,
////                                    ),
////                                  ),
////                                ],
////                              ),
////                            ),
////                          ),
////                          SizedBox(
////                            width: 3.0,
////                          ),
////                          isFollowed? GestureDetector(
////                            onTap: (){
////                              setState(() {
////                                if(isFollowed){
////                                  if(isExpanded){
////                                    isExpanded=false;
////                                    isShowed=false;
////                                    totalHeight=totalHeight-recommendHeight;
////                                  }else{
////                                    isExpanded=true;
////                                    isShowed=true;
////                                    totalHeight=totalHeight+recommendHeight;
////                                  }
////                                }
////                                if(isFollowed && !isExpanded){
////                                  first=false;
////                                }else{
////                                  first=true;
////                                }
////                              });
////                            },
////                              child: Container(
////                                height: 20.0,width: 20.0,
////                                decoration: BoxDecoration(
////                                  color: Colors.white,
////                                  borderRadius: BorderRadius.circular(5.0),
////                                  border: Border.all(
////                                    color: Colors.black12,
////                                    width: 1.0,
////                                  ),
////                                ),
////                                child: Center(
////                                  child: Icon(isExpanded? Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,
////                                    size: 18.0,
////                                    color: Colors.grey,),
////                                ),
////                              ))
////                              :
////                          Container(),
////                        ],
////                      ),
////                    ),
////                  ),
////                ),
              ],
            ),
          ),
          (isShowed)? Container(
            height: recommendHeight.toDouble(),
            color: Colors.black12,
            child: Visibility(
              visible: true,
                child: RelevantRecommendation()),
          ) : Container(),
          GestureDetector(
            onTap: (){
              //_setPage(context);
            },
            child: Container(
              height: captionHeight.toDouble(),
              padding: EdgeInsets.only(top: 5.0,left: 10.0,right: 10.0,),
              child: Text('An example of a bee sucking honey and bring those to their home and I fell very awesome with natural and love to watch those kind of document and I would like to explore natural thing like that through my whole life',
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  height: 1.5,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              //_setPage(context);
            },
            child: imgHeight==0 ? Container() :
            Container(
              padding: EdgeInsets.only(left: 8.0,right: 8.0),
                child: MomentImage(height: imgHeight,image: imgList,)),
          ),
          Container(
            color: Colors.black12,
            height: dividerHeight.toDouble(),
          ),
          Container(
            height: likeHeight.toDouble(),
            padding: EdgeInsets.only(left: 10.0,right: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(Icons.thumb_up,size: 15.0,color: isLiked? Colors.blue:Colors.grey,),
                        onTap: (){
                              setState(() {
                                if(isLiked){
                                  isLikedTo(false);
                                  like=like-1;
                                }else{
                                  isLikedTo(true);
                                  like=like+1;
                                }
                                updateLike(moment.momentPostID,like);
                              });
                        },
                        ),
                        SizedBox(width: 5.0,),
                        Text(like.toString(),
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0
                            ),
                          ),
                      ],
                    ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => CommentPage())
                        );
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.comment,size: 15.0,color: Colors.grey,),
                        SizedBox(width: 5.0,),
                        Text(comment.toString(),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.share,size: 15.0,color: Colors.grey,),
                      SizedBox(width: 5.0,),
                      Text('1000',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0
                          ),
                        ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 5.0,
            padding: EdgeInsets.only(top: 3.0,),
            color: Colors.black12,
          ),
        ],
      ),
    );
  }

  void _setPage(BuildContext context) {
    setState(() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MomentPageDetails(image: imgList,follow: isFollowed,moment: moment,following: following,))
      );
    });
  }

  void isLikedTo(bool param0) {
    setState(() {
      isLiked=param0;
    });
  }

}
