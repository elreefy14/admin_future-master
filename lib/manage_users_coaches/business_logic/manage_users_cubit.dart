import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../registeration/data/userModel.dart';
import '../../registeration/presenation/widget/widget.dart';
import '../../home/data/Notification.dart';
import '../../home/data/day_model.dart';
import '../../home/data/schedules.dart';
import '../../home/presenation/widget/manage_groups_screen.dart';
part 'manage_users_state.dart';
class ManageUsersCubit extends Cubit<ManageUsersState> {

  //final UserModel userModel;
  ManageUsersCubit() : super(ManageSalaryInitial());
  static ManageUsersCubit get(context) => BlocProvider.of(context);
  bool isSearch = false;
  Query? usersQuery;
  final TextEditingController searchController = TextEditingController();

  //  void updateIsSearch(bool bool) {
  //     isSearch = bool;
  //     emit(state.copyWith(isSearch: bool));
  //   }
  //Future<void> onSearchSubmitted(String value, bool isCoach) async {
  //     late Query newQuery;
  //     if (isCoach)
  //       newQuery = FirebaseFirestore.instance
  //           .collection('users')
  //           .orderBy('name')
  //           .startAt([value])
  //           .endAt([value + '\uf8ff'])
  //           .where('role', isEqualTo: 'coach')
  //           .limit(100);
  //     else
  //       newQuery = FirebaseFirestore.instance
  //           .collection('users')
  //           .orderBy('name')
  //           .startAt([value])
  //           .endAt([value + '\uf8ff'])
  //           .where('role', isEqualTo: 'user')
  //           .limit(100);
  //
  //     QuerySnapshot querySnapshot =
  //         await newQuery.get(GetOptions(source: Source.serverAndCache));
  //     var numberOfQuery = querySnapshot.docs.length;
  //     print('number of query is $numberOfQuery');
  //     print(numberOfQuery);
  //
  //     if (numberOfQuery == 0) {
  //       if (isCoach)
  //         newQuery = FirebaseFirestore.instance
  //             .collection('users')
  //             .where('phone', isGreaterThanOrEqualTo: value)
  //             .where('phone', isLessThan: value + 'z')
  //             //order by name
  //             .orderBy('phone', descending: false)
  //             .where('role', isEqualTo: 'coach')
  //             .limit(100);
  //       else
  //         newQuery = FirebaseFirestore.instance
  //             .collection('users')
  //             .where('phone', isGreaterThanOrEqualTo: value)
  //             .where('phone', isLessThan: value + 'z')
  //             //order by name
  //             .orderBy('phone', descending: false)
  //             .where('role', isEqualTo: 'user')
  //             .limit(100);
  //     }
  //     //update query
  //     updateQuery(newQuery);
  //   }
  // void updateQuery(Query query) {
  //   usersQuery = query;
  //   emit(state.copyWith(query: query));
  // }
  //  void updateUsersQuery(param0) {
  //     usersQuery = param0;
  //     emit(state.copyWith(query: param0));
  //   }
  //  void updateIsSearch(bool bool) {
  //     isSearch = bool;
  //     emit(state.copyWith(isSearch: bool));
  //   }












  bool isGrey = false;
  TabController? tabController;
  //messageController
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController salaryPerHourController;
  //numberOfSessionsController
  late TextEditingController numberOfSessionsController;
  //init tab controller
  void initTabController() {
    tabController = TabController(length: 2, vsync: NavigatorState());
  }
  void initControllers(userModel) {
    firstNameController = TextEditingController(text: userModel.fname);
    lastNameController = TextEditingController(text: userModel.lname);
    phoneController = TextEditingController(text: userModel.phone);
    salaryPerHourController =
        TextEditingController(text: userModel.hourlyRate.toString() ?? '');
    //numberOfSessionsController
    numberOfSessionsController =
        TextEditingController(text: userModel.numberOfSessions.toString() ?? '');

  }
  //make function that take phone number and add that phone to whatsapp group

  bool isCoach = true;
  //change isCoach
  void changeIsCoach(bool value) {
    isCoach = value;
    emit(ChangeIsCoachState(
      isCoach!,
    ));
  }

  //changeSelectedDayIndex
  int selectedDayIndex = 0;
  void changeSelectedDayIndex(int index) {
    selectedDayIndex = index;
    emit(ChangeSelectedDayIndexState(
      selectedDayIndex,
    ));
  }

  //get list of next 7 days from today and prind the day like friday in arabic

  List<DayModel> days = [];
  String? today;

  getDays() async {
    emit(GetDaysLoadingState());
//dalay 5 seconds
//   await  Future.delayed(const Duration(seconds: 5), () {
//       print('delayed');
//     });
    days = [];
    if (kDebugMode) {
      print('getDays\n\n\n');
    }
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      String day = date.weekday.toString();
      switch (day) {
        case '1':
          day = 'الاثنين';
          break;
        case '2':
          day = 'الثلاثاء';
          break;
        case '3':
          day = 'الأربعاء';
          break;
        case '4':
          day = 'الخميس';
          break;
        case '5':
          day = 'الجمعة';
          break;
        case '6':
          day = 'السبت';
          break;
        case '7':
          day = 'الأحد';
          break;
        //,make random dummy values list of days
        //['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
      }
      Timestamp timestamp = Timestamp.fromDate(date);
      days.add(DayModel(name: day, timestamp: timestamp));
      //print list of days
      if (kDebugMode) {
        print('days: $days');
      }
    }
    today = days[0].name;
    emit(GetDaysSuccessState());
  }

  //get list of schedules from admin collection then schedule subcollection for specific day like friday
  List<ScheduleModel> schedules = [];
  Future<void> getSchedules({required String day}) async {
    print('a7a \n\n\n\n');
    print('day: $day');
    emit(GetSchedulesLoadingState());
    schedules = [];
    await FirebaseFirestore.instance
        .collection('admins')
        //todo change this to admin id
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('schedules')
        .doc(day)
        .collection('schedules')
        .get(const GetOptions(source: Source.serverAndCache))
        .then((value) {
      value.docs.forEach((element) {
        schedules.add(ScheduleModel.fromJson2(element.data()));
        //print list of schedules
      });
      //print all info for each schedule
      if (kDebugMode) {
        schedules.forEach((element) {
          print('branchId: ${element.branchId}');
          print('startTime: ${element.startTime}');
          print('endTime: ${element.endTime}');
          //print end time like that 12 : 00
          print(
              'endTime: ${element.endTime?.toDate().hour} : ${element.endTime?.toDate().minute}');
          print('usersList: ${element.usersList}');
        });
      }
      emit(GetSchedulesSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(GetSchedulesErrorState(error.toString()));
    });
  }

  // List<UserModel> users = [];
  // Future<void> getUsers() async {
  //   emit(GetUsersLoadingState());
  //   users = [];
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('role', isEqualTo: 'user') // filter by role
  //       .get(GetOptions(source: Source.serverAndCache))
  //       .then((value) {
  //     value.docs.forEach((element) {
  //       users.add(UserModel.fromJson(element.data()));
  //     });
  //     emit(GetUsersSuccessState());
  //   }).catchError((error) {
  //     print(error.toString());
  //     emit(GetUsersErrorState(error.toString()));
  //   });
  // }
  //
  // List<UserModel> coaches = [];
  // Future<void> getCoaches() async {
  //   emit(GetUsersLoadingState());
  //   coaches = [];
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('role', isEqualTo: 'coach') // add this line to filter by role
  //       .get(GetOptions(source: Source.serverAndCache))
  //       .then((value) {
  //     num totalSalary = 0; // Change the type of totalSalary to num
  //     value.docs.forEach((element) {
  //       coaches.add(UserModel.fromJson(element.data()));
  //       totalSalary += element.data()['totalSalary'];
  //     });
  //     globalTotalSalary =
  //         totalSalary; // Assign totalSalary value to globalTotalSalary
  //     print('Total salary of all users: $globalTotalSalary');
  //     emit(GetUsersSuccessState());
  //   }).catchError((error) {
  //     print(error.toString());
  //     emit(GetUsersErrorState(error.toString()));
  //   });
  // }

  checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void saveSalaryLocally(String? userId, int newTotalSalary) {
    // Save the updated salary locally until an internet connection is available
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(userId!, newTotalSalary);
    });
  }

  //sync data from local to firestore when internet is available
  //check if internet is available
  void syncData() async {
    bool isConnected = await checkInternetConnectivity();
    if (isConnected) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.getKeys().forEach((key) async {
          int? newTotalSalary = prefs.getInt(key);
          if (newTotalSalary != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(key)
                .update({'totalSalary': newTotalSalary});
          }
        });
      });
      //clear local data
      SharedPreferences.getInstance().then((prefs) {
        prefs.clear();
      });
    }
  }

//  void editUserData({
//     String? firstName,
//     String? lastName,
//     String? phone,
//     String? image,
//   }) async {
//     emit(EditUserDataLoadingState());
//     final user = FirebaseAuth.instance.currentUser;
//     final updateData = <String, Object?>{};
//     final notificationData = <String, dynamic>{};
//
//     if (firstName != null || lastName != null) {
//       updateData['name'] = firstName??'' + ' ' + (lastName ?? '');
//       //userData!.name = firstName + ' ' + (lastName ?? '');
//     }
//     if (firstName != null) {
//       updateData['fname'] = firstName;
//       updateData['name'] = firstName + ' ' + (lastName ?? '');
//
//       //userData!.fname = firstName;
//       notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
//     }
//     if (lastName != null) {
//       updateData['lname'] = lastName;
//       updateData['name'] = firstName??'' + ' ' + (lastName ?? '');
//      // userData!.lname = lastName;
//       notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
//     }
//     if (phone != null) {
//       updateData['phone'] = phone;
//      // userData!.phone = phone;
//       notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
//     }
//     if (image != null) {
//       updateData['image'] = image;
//
//       //userData!.image = image;
//       notificationData['message'] = ' تم تحديث معلومات الحساب الشخصية';
//     //'personal info '
//       //translation
//
//        }
//
//
//     // Update the user data
//     try {
//      // CacheHelper.saveUser(userData);
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .update(updateData);
//
//       // Update the local cache
//       CacheHelper.getUser()!.then((userData) async {
//           if (firstName != null) {
//             userData!.fname = firstName ;
//           }
//           if (lastName != null) {
//             userData!.lname = lastName ;
//           }
//         if (firstName != null || lastName != null) {
//           userData!.name = firstName??'' + ' ' + (lastName ?? '');
//         }
//         if (phone != null) {
//           userData!.phone = phone;
//         }
//         if (image != null) {
//           userData!.image = image;
//         }
//         CacheHelper.saveUser(userData);
//        await getUserData();
//
//       });
//       // Add notification to the subcollection
//       notificationData['timestamp'] = DateTime.now();
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .add(notificationData);
//
//       emit(EditUserDataSuccessState());
//     } catch (error) {
//       print(error.toString());
//       emit(EditUserDataErrorState(error.toString()));
//     }
//   }
//make update user info like above function
  Future<bool> checkInternetConnection() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
  Future<void>? updateUserInfo(
      {required String fname,
      required String lname,
      required String phone,
        String? hourlyRate,

      required uid, required String? numberOfSessions}) async {
    emit(UpdateUserInfoLoadingState());
    // Inside your function
bool isConnected = await checkInternetConnection();
// if (!isConnected) {
//
//   // Show error message to the user
//   //show toast message
//   showToast(
//     state: ToastStates.ERROR,
//     msg: ' فشل تحديث معلومات الحساب الشخصية'
//     'تأكد من اتصالك بالإنترنت'
//   );
//   emit(UpdateUserInfoErrorState('تأكد من اتصالك بالإنترنت'));
// }
    final updateData = <String, Object?>{};
    print('hourlyRate: $hourlyRate');
    print('fname: $fname');
    print('lname: $lname');
    print('phone: $phone');
    print('numberOfSessions: $numberOfSessions');


    final notificationData = <String, dynamic>{};
    if (hourlyRate != null && hourlyRate != '' && hourlyRate != 'null') {
      print('hourlyRate: a7a $hourlyRate');
      updateData['hourlyRate'] = int.parse(hourlyRate);
      notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
    }
    if (numberOfSessions != null &&
        numberOfSessions != '' &&
        numberOfSessions != 'null') {
      print('numberOfSessions: a7a $numberOfSessions');
      updateData['numberOfSessions'] = int.parse(numberOfSessions);
      notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
    }
    if (fname != null &&
        lname != null &&
        fname != '' &&
        lname != '' &&
        fname != 'null' &&
        lname != 'null') {
      updateData['name'] = '$fname $lname';
      updateData['fname'] = fname;
      updateData['lname'] = lname;

      //userData!.name = firstName + ' ' + (lastName ?? '');
    }
    if (fname != null && fname != '' && fname != 'null') {
      updateData['fname'] = fname;
      notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
    }
    if (lname != null && lname != '' && lname != 'null') {
      updateData['lname'] = lname;
      notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
    }
    if (phone != null && phone != '' && phone != 'null') {
      print('phone: a7a $phone');
      updateData['phone'] = phone.toString();
      notificationData['message'] = 'تم تحديث معلومات الحساب الشخصية';
    }
    //print updateData
    print('updateData: $updateData');

    notificationData['timestamp'] = DateTime.now();
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .collection('notifications')
    //     .add(notificationData);
     FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(updateData);
  //if internet is not available show toast message
  //and emit state
    if (!isConnected) {
      // Show message user updated successfully
      //but data will be synced when internet is available
      //show toast message
      showToast(
        state: ToastStates.SUCCESS,
        msg: 'تم تحديث معلومات الحساب الشخصية'
        'سيتم مزامنة البيانات عند توفر الإنترنت',
      );
      emit(UpdateUserInfoSuccessState());
    }
    else {
      showToast(
      state: ToastStates.SUCCESS,
      msg: 'تم تحديث معلومات الحساب الشخصية',
    );
      emit(UpdateUserInfoSuccessState());

    }
  }


  Future<void> updatePassword(String password, String? uid) async {
    try {
      // Get the user using the uid
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userSnapshot.exists) {
        print('User not found');
        return;
      }

      // Get the user ID
      final userId = userSnapshot.id;

      // Update password
      await FirebaseAuth.instance.currentUser!.updatePassword(password);

      print('Successfully changed password');
    } catch (error) {
      print('Password change failed: $error');
    }
  }

  Future<void> sendMessage(
      {required BuildContext context, required String message, String? uid}) {
    //add notification to the subcollection of the user who will receive the message
    NotificationModel notification = NotificationModel(
      message: message,
      timestamp: DateTime.now(),
    );
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add(notification.toMap())
        .then((value) {
      print('Notification added');
      //show toast message
      showToast(
        state: ToastStates.SUCCESS,
        msg: 'تم إرسال الرسالة',
      );
    }).catchError((error) {
      print('Failed to add notification: $error');
      showToast(msg: 'فشل إرسال الرسالة', state: ToastStates.ERROR);
    });
  }

  void getSchedulesForDay(String day) {
    emit(GetSchedulesForDayLoadingState());
    schedules = [];
    FirebaseFirestore.instance
        .collection('admins')
        //todo change this to admin id
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('schedules')
        .doc(day)
        .collection('schedules')
        .get(const GetOptions(source: Source.serverAndCache))
        .then((value) {
      value.docs.forEach((element) {
        schedules.add(ScheduleModel.fromJson2(element.data()));
      });
      emit(GetSchedulesForDaySuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(GetSchedulesForDayErrorState(error.toString()));
    });
  }

  Future<void> deleteSchedule({
  required String scheduleId,
  required String day,
  required List<String>? usersIds,
   List<String>? coachesIds,
}) async {
  emit(DeleteScheduleLoadingState());

  try {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Delete the schedule document
    DocumentReference scheduleRef = FirebaseFirestore.instance
        .collection('admins')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('schedules')
        .doc(day)
        .collection('schedules')
        .doc(scheduleId);
    batch.delete(scheduleRef);

    // Delete the users subcollection
    CollectionReference usersRef = scheduleRef.collection('users');
    QuerySnapshot usersSnapshot = await usersRef.get();
    usersSnapshot.docs.forEach((doc) {
      batch.delete(doc.reference);
    });

    // Commit the batched write
    await batch.commit();

    // Remove the schedule from the list of schedules
    schedules.removeWhere((schedule) => schedule.scheduleId == scheduleId);

    // Delete the schedule from each user's collection
    if (usersIds != null) {
      for (String userId in usersIds) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('schedules')
            .doc(scheduleId)
            .delete();
        print('Schedule deleted from user $userId');
      }
    }
     // Delete the schedule from each coach's collection
    if (coachesIds != null) {
      for (String coachId in coachesIds) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(coachId)
            .collection('schedules')
            .doc(scheduleId)
            .delete();
        print('Schedule deleted from coach $coachId');
      }
    }
    emit(DeleteScheduleSuccessState());
  } catch (error) {
    print(error.toString());
    emit(DeleteScheduleErrorState(error.toString()));
  }
}

  void updateSchedules(ScheduleModel schedule) {
    emit(UpdateSchedulesLoadingState());
    schedules.add(schedule);
    //sort based on start time
    schedules.sort((a, b) => a.startTime!.compareTo(b.startTime!));
    emit(UpdateSchedulesSuccessState());
  }

  void changeIsGrey(bool bool) {
    isGrey = bool;
    emit(ChangeIsGreyState(
      isGrey,
    ));
  }

  // void updateListOfCoaches(List users14) {
  //   //merge user14 with users
  //   coaches = [];
  //   coaches.addAll(users14 as Iterable<UserModel>);
  //   emit(UpdateListOfUsersState(
  //     coaches,
  //   ));
  // }

  // void updateListOfUsers(List users14) {
  //   //merge user14 with users
  //   users = [];
  //   users.addAll(users14 as Iterable<UserModel>);
  //   emit(UpdateListOfUsersState(
  //     users,
  //   ));
  // }


   deleteUser({required String uid}) {
    emit(DeleteUserLoadingState());

    // Delete the user document
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .delete()
        .then((value) {
      print('User deleted');

      // Delete the user's subcollection "schedules"
      CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('users').doc(uid).collection('schedules');
      schedulesCollection.get().then((schedulesSnapshot) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        schedulesSnapshot.docs.forEach((doc) {
          batch.delete(doc.reference);
        });
        batch.commit().then((_) {
          // Show toast message
          showToast(
            state: ToastStates.SUCCESS,
            msg: 'تم حذف المستخدم والجداول الفرعية',
          );
          emit(DeleteUserSuccessState());
        }).catchError((error) {
          print('Failed to delete user schedules: $error');
          showToast(
            msg: 'فشل حذف الجداول الفرعية',
            state: ToastStates.ERROR,
          );
          emit(DeleteUserErrorState(error.toString()));
        });
      });
    }).catchError((error) {
      print('Failed to delete user: $error');
      showToast(
        msg: 'فشل حذف المستخدم',
        state: ToastStates.ERROR,
      );
      emit(DeleteUserErrorState(error.toString()));
    });
  }

  //    bool isConnected = await checkInternetConnectivity();
//edit this function to enable it when internet is not available
//by show toast message
//and emit state
//then pop 
//use firebase persistance to get data from cache

  bool showRollbackButton = false;
  int? currentTotalSalary ;
  int? currentNumberOfSessions ;
  String? latestUserId;
  addSessions(context, {String? userId,
    String? userName,
    required String sessions,
   required int NumberOfSessions
  }) async {
    emit(AddSessionsLoadingState());
   currentNumberOfSessions = NumberOfSessions;
   latestUserId = userId;
    bool isConnected = await checkInternetConnectivity();
    //get time stamp for the current month and year
    //String monthAndYear = DateTime.now().month.toString() +
    //    '-' +
    //    DateTime.now().year.toString();
    if (isConnected) {
      //go to branches collection and doc with branchId then collection date then doc with month and year then update field number of sessions
      //         FirebaseFirestore.instance
      //       .collection('branches')
      //       .doc(branchId)
      //       .collection('dates')
      //       .doc(monthAndYear)
      //       .update({'numberOfSessions':
      //       FieldValue.increment(int.parse(sessions))});
      FirebaseFirestore.instance
          .collection('admins')
          .doc( FirebaseAuth.instance.currentUser?.uid)
          .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
        if (value.exists) {
//add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .update({
            'numberOfSessions': FieldValue.increment(int.parse(sessions))
          });
        } else {
          //create new document and add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .set({
            'numberOfSessions':int.parse(sessions)
          });
        }
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'numberOfSessions': FieldValue.increment(int.parse(sessions))})
          .then((value) {
        print('Sessions added');
        //show toast message
        //add notification to admin
        NotificationModel notification = NotificationModel(
          //message indicate that admin add sessions to user name  with number of sessions
          message: 'تم زيادة عدد الجلسات للمستخدم $userName بعدد $sessions جلسة',
          timestamp: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('admins')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .add(notification.toMap());

        salaryController.clear();
        emit(AddSessionsSuccessState());
   //     Navigator.pop(context);
     //   showToast(
     //     state: ToastStates.SUCCESS,
     //     msg: 'تم زيادة عدد الجلسات',
     //   );
        //show rollback button for 5 seconds
        showRollbackButton = true;
        //5 seconds
        Future.delayed(Duration(seconds: 5), () {
          showRollbackButton = false;
          emit(AddSessionsSuccessState());
        });

      }).catchError((error) {
        print('Failed to add sessions: $error');
        showToast(msg: 'فشل زيادة عدد الجلسات', state: ToastStates.ERROR);
        emit(AddSessionsErrorState(error.toString()));
      });
    } else {


      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(GetOptions(source: Source.serverAndCache));
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      UserModel user = UserModel.fromJson(userData!);
      user.numberOfSessions = user.numberOfSessions! + int.parse(sessions);
       FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'numberOfSessions': FieldValue.increment(int.parse(sessions))});
      FirebaseFirestore.instance
          .collection('admins')
          .doc( FirebaseAuth.instance.currentUser?.uid)
          .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
        if (value.exists) {
//add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .update({
            'numberOfSessions': FieldValue.increment(int.parse(sessions))
          });
        } else {
          //create new document and add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .set({
            'numberOfSessions':int.parse(sessions)
          });
        }
      });
       //add users to user collection wih random
      //    required String lName,
      //     required String fName,
      //     required String phone,
      //     required String password,
      //     required String role,  String? hourlyRate,
   //todo :5od dh w kleh offline f sign up
      // print('a7aaaaaaaaaaaaaaaaaaaaaaa;\n\n\n\n\n\n\n\n\n\n\n\n\n\n');
      // FirebaseFirestore.instance
      //     .collection('users')
      //     .doc('a7ajhbjh')
      //     .set({'numberOfSessions': FieldValue.increment(int.parse(sessions))
      //     ,'fname':'no wifi','lname':'no wifi','phone':'ko','password':'123456','role':'user'
      //   ,'hourlyRate':0
      //     });
     // showToast(
     //   state: ToastStates.SUCCESS,
      //  msg: 'تم زيادة عدد الجلسات '
     //       'سيتم تحديث البيانات عند توفر الإنترنت',
     // );
        print('Sessions added');
      showRollbackButton = true;
      //5 seconds
      Future.delayed(Duration(seconds: 5), () {
        showRollbackButton = false;
      //  emit(AddSessionsSuccessState());
      });
      //debug showRollbackButton
      print('\n\n\n\nshowRollbackButton: $showRollbackButton');

      //show toast message
      NotificationModel notification = NotificationModel(
        //message indicate that admin add sessions to user name  with number of sessions
        message: 'تم زيادة عدد الجلسات للمستخدم $userName بعدد $sessions جلسة',
        timestamp: DateTime.now(),
      );
      FirebaseFirestore.instance
          .collection('admins')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .add(notification.toMap());
        salaryController.clear();
        emit(AddSessionsSuccessState());
      //  Navigator.pop(context);

    }
  }

  reduceSessions(   context,{String? userId,
    String? userName,
    required String sessions,
    required int NumberOfSessions
  }

      ) async {
    emit(ReduceSessionsLoadingState());
      currentNumberOfSessions = NumberOfSessions;
      latestUserId = userId;

    bool isConnected = await checkInternetConnectivity();
    if (isConnected) {
      FirebaseFirestore.instance
          .collection('admins')
          .doc( FirebaseAuth.instance.currentUser?.uid)
          .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
        if (value.exists) {
//add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .update({
            'numberOfAttendence': FieldValue.increment(int.parse(sessions))
          });
        } else {
          //create new document and add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .set({
            'numberOfAttendence':int.parse(sessions)
          });
        }
      });
       FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'numberOfSessions': FieldValue.increment(-int.parse(sessions))});

        print('Sessions reduced');
        showRollbackButton = true;
        //5 seconds
        Future.delayed(Duration(seconds: 5), () {
          showRollbackButton = false;
           emit(ReduceSessionsSuccessState());
        });
        print('showRollbackButton: $showRollbackButton');
        NotificationModel notification = NotificationModel(
          message: 'تم تخفيض عدد الجلسات للمستخدم $userName بعدد $sessions جلسة',
          timestamp: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('admins')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .add(notification.toMap());
        salaryController.clear();
        emit(ReduceSessionsSuccessState());
        return;
        //   Navigator.pop(context);

    } else {

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(GetOptions(source: Source.serverAndCache));
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      UserModel user = UserModel.fromJson(userData!);
      user.numberOfSessions = user.numberOfSessions! - int.parse(sessions);
       FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'numberOfSessions': FieldValue.increment(-int.parse(sessions))});
      FirebaseFirestore.instance
          .collection('admins')
          .doc( FirebaseAuth.instance.currentUser?.uid)
          .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
        if (value.exists) {
//add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .update({
            'numberOfAttendence': FieldValue.increment(int.parse(sessions))
          });
        } else {
          //create new document and add number of sessions to it
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates')
              .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
              .set({
            'numberOfAttendence':int.parse(sessions)
          });
        }
      });

       //       FirebaseFirestore.instance
//           .collection('admins')
//           .doc( FirebaseAuth.instance.currentUser?.uid)
//           .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
//         if (value.exists) {
// //add number of sessions to it
//           FirebaseFirestore.instance
//               .collection('admins')
//               .doc( FirebaseAuth.instance.currentUser?.uid)
//               .collection('dates')
//               .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
//               .update({
//             'numberOfSessions': FieldValue.increment(-int.parse(sessions))
//           });
//         } else {
//           //create new document and add number of sessions to it
//           FirebaseFirestore.instance
//               .collection('admins')
//               .doc( FirebaseAuth.instance.currentUser?.uid)
//               .collection('dates')
//               .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
//               .set({
//             'numberOfSessions':-int.parse(sessions)
//           });
//         }
//       });

      print('Sessions reduced');
        //show toast message
      //  showToast(
      //    state: ToastStates.SUCCESS,
      //    msg: 'تم تخفيض عدد الجلسات '
      //        'سيتم تحديث البيانات عند توفر الإنترنت',
       // );
      NotificationModel notification = NotificationModel(
        message: 'تم تخفيض عدد الجلسات للمستخدم $userName بعدد $sessions جلسة',
        timestamp: DateTime.now(),
      );
      FirebaseFirestore.instance
          .collection('admins')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .add(notification.toMap());
        salaryController.clear();
        //
        showRollbackButton = true;
        //5 seconds
        Future.delayed(Duration(seconds: 5), () {
          showRollbackButton = false;
          print('\n\n\nshowRollbackButton: $showRollbackButton');
          emit(ReduceSessionsSuccessState());
        });
        emit(ReduceSessionsSuccessState());
       // Navigator.pop(context);
        return;
    }

  }

  num globalTotalSalary = 0; // Declare globalTotalSalary variable as num
// salary textEditingController
  TextEditingController salaryController = TextEditingController();
  //firstNameController

// update total salary of all users
  //make total salary = 0
  //for user with this uid userId
  //use catch error

  Future<void> paySalary({
    String? userId,
    String? userName,
    int? userTotalSalary,
  }) async {
    try {
      //print total salary of all users
      print('Total salary user: $userTotalSalary');
      latestUserId = userId;
      print('userId: $userId');
      emit(PaySalaryLoadingState());
      bool isConnected = await checkInternetConnectivity();

      if (!isConnected) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(GetOptions(source: Source.serverAndCache));


        Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
        UserModel user = UserModel.fromJson(userData!);
        user.totalSalary = 0;
        FirebaseFirestore.instance
            .collection('admins')
            .doc( FirebaseAuth.instance.currentUser?.uid)
            .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
          if (value.exists) {
//add number of sessions to it
            FirebaseFirestore.instance
                .collection('admins')
                .doc( FirebaseAuth.instance.currentUser?.uid)
                .collection('dates')
                .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                .update({
              //totalSalary
              'totalSalary': FieldValue.increment(int.parse(userTotalSalary.toString())),
              // 'totalHours': FieldValue.increment(-totalHours),
            });
          } else {
            //create new document and add number of sessions to it
            FirebaseFirestore.instance
                .collection('admins')
                .doc( FirebaseAuth.instance.currentUser?.uid)
                .collection('dates')
                .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                .set({
              //totalSalary
              'totalSalary': int.parse(userTotalSalary.toString()),
              //  'totalHours': 0,
            });
          }
        });
       FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'totalSalary': 0});
       print('Total salary of all users: $globalTotalSalary');
     //  showToast(
      //      state: ToastStates.SUCCESS,
     //       msg: //pay salary success
     //       'تم صرف المرتب بنجاح',
     //     );
        showRollbackButton = true;
        //delay 5 seconds
        Timer(Duration(seconds: 5), () {
          showRollbackButton = false;
          emit(ShowRollbackButtonState());
        });
        NotificationModel notification = NotificationModel(
          message: 'تم صرف المرتب كامل للمستخدم ${user.name} ',
          timestamp: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('admins')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .add(notification.toMap());
        salaryController.clear();
          emit(PaySalarySuccessStateWithoutInternet());
          return;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(GetOptions(source: Source.server));

      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        currentTotalSalary = userData['totalSalary'] ?? 0;
        int newTotalSalary = 0;

        // Only update the user's total salary if it has changed
        if (currentTotalSalary != newTotalSalary) {
          // Save the current total salary locally before updating it
          saveSalaryLocally(userId, currentTotalSalary!);
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
            if (value.exists) {
//add number of sessions to it
              FirebaseFirestore.instance
                  .collection('admins')
                  .doc( FirebaseAuth.instance.currentUser?.uid)
                  .collection('dates')
                  .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                  .update({
                //totalSalary
                'totalSalary': FieldValue.increment(int.parse(userTotalSalary.toString())),
                // 'totalHours': FieldValue.increment(-totalHours),
              });
            } else {
              //create new document and add number of sessions to it
              FirebaseFirestore.instance
                  .collection('admins')
                  .doc( FirebaseAuth.instance.currentUser?.uid)
                  .collection('dates')
                  .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                  .set({
                //totalSalary
                'totalSalary': int.parse(userTotalSalary.toString()),
                //  'totalHours': 0,
              });
            }
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'totalSalary': newTotalSalary});

          // Update the user in the users list
          UserModel updatedUser = UserModel.fromJson(userData);
          updatedUser.totalSalary = newTotalSalary;
        //  int userIndex = coaches.indexWhere((user) => user.uId == userId);
       //   if (userIndex != -1) {
       //     coaches[userIndex] = updatedUser;
      //    }

          // Show elevated button if user wants to rollback this action
          showRollbackButton = true;
          //delay 5 seconds
          Timer(Duration(seconds: 5), () {
            showRollbackButton = false;
            emit(ShowRollbackButtonState());
          });

          // showToast(
          //   state: ToastStates.SUCCESS,
          //   msg: //pay salary success
          //   'تم صرف المرتب بنجاح',
          // );
          NotificationModel notification = NotificationModel(
            message: 'تم صرف كامل المرتب للمستخدم ${userName}',
            timestamp: DateTime.now(),
          );
          FirebaseFirestore.instance
              .collection('admins')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('notifications')
              .add(notification.toMap());
          salaryController.clear();
          emit(PaySalarySuccessState());
        } else {
          //emit(PaySalarySuccessStateWithoutUpdate());
        }
      } else {
        throw 'User data not found';
      }
    } catch (error) {
      print(error.toString());
      emit(PaySalaryErrorState(error.toString()));
    }
  }
  Future<void> rollbackSalary(
      ) async {
    try {
      bool isConnected = await checkInternetConnectivity();
      if (!isConnected) {
        // DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        //           .collection('users')
        //           .doc(userId)
        //           .get(GetOptions(source: Source.serverAndCache));
        //       Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        //       UserModel user = UserModel.fromJson(userData!);
        //       user.numberOfSessions = user.numberOfSessions! - int.parse(sessions);
        //        FirebaseFirestore.instance
        //           .collection('users')
        //           .doc(userId)
        //           .update({'numberOfSessions': FieldValue.increment(-int.parse(sessions))});
        //
        //         print('Sessions reduced');
        //         //show toast message
        //         showToast(
        //           state: ToastStates.SUCCESS,
        //           msg: 'تم تخفيض عدد الجلسات '
        //               'سيتم تحديث البيانات عند توفر الإنترنت',
        //         );
        //         salaryController.clear();
        //         emit(ReduceSessionsSuccessState());
        //        // Navigator.pop(context);
        //show toast message
        print('latestUserId: $latestUserId');
        print('currentTotalSalary: $currentTotalSalary');
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(latestUserId)
                  .get(GetOptions(source: Source.serverAndCache));
              Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
              UserModel user = UserModel.fromJson(userData!);
              user.totalSalary = currentTotalSalary;
               FirebaseFirestore.instance
                  .collection('users')
                  .doc(latestUserId)
                  .update({'totalSalary': currentTotalSalary});

                print('Total salary of all users: $globalTotalSalary');

        showToast(
          state: ToastStates.SUCCESS,
          msg: 'تم التراجع عن العملية '
              'سيتم تحديث البيانات عند توفر الإنترنت',
        );
        emit(RollbackSalarySuccessStateWithoutInternet());
        return;
      }

      // emit(RollbackSalaryLoadingState());
      print('latestUserId: $latestUserId');
      print('currentTotalSalary: $currentTotalSalary');


      await FirebaseFirestore.instance
          .collection('users')
          .doc(latestUserId)
          .update({'totalSalary': currentTotalSalary});
      // Update the user in the users list
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(latestUserId)
          .get(GetOptions(source: Source.server));

      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      UserModel updatedUser = UserModel.fromJson(userData!);
      updatedUser.totalSalary = currentTotalSalary;
    //  int userIndex = coaches.indexWhere((user) => user.uId == latestUserId);
    //  if (userIndex != -1) {
    //    coaches[userIndex] = updatedUser;
    //  }


      //   Map<String, dynamic>? userData =
      //       userSnapshot.data() as Map<String, dynamic>?;

      //   if (userData != null) {
      //     int currentTotalSalary = userData['totalSalary'] ?? 0;

      //     // Only update the user's total salary if it has changed
      //     if (currentTotalSalary != latestUserId) {
      //       await FirebaseFirestore.instance
      //           .collection('users')
      //           .doc(latestUserId)
      //           .update({'totalSalary': currentTotalSalary});

      //       // Update the user in the users list
      //       UserModel updatedUser = UserModel.fromJson(userData);
      //       updatedUser.totalSalary = currentTotalSalary;
      //       int userIndex = coaches.indexWhere((user) => user.uId == latestUserId);
      //       if (userIndex != -1) {
      //         coaches[userIndex] = updatedUser;
      //       }

      // //      emit(RollbackSalarySuccessState());
      //     } else {
      // //      emit(RollbackSalarySuccessStateWithoutUpdate());
      //     }
      //   } else {
      //     throw 'User data not found';
      //   }
      //show toast message
      showToast(
        state: ToastStates.SUCCESS,
        msg: 'تم التراجع عن العملية',
      );
    } catch (error) {
      print(error.toString());
      //  emit(RollbackSalaryErrorState(error.toString()));
    }
  }

//updateShowRollbackButton
  Future<void> updateShowRollbackButton(
      ) async {
    emit(UpdateShowRollbackButtonLoadingState());
    showRollbackButton = false;
    emit(UpdateShowRollbackButtonSuccessState());
  }

  //
  Future<void> payPartialSalary({String? userId, String? salaryPaid,
     String? userName,
  required int currentTotalSalary
  }) async {
    try {
      latestUserId = userId;

      print('userId: $userId');
      emit(PaySalaryLoadingState());

      bool isConnected = await checkInternetConnectivity();

      if (!isConnected) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(GetOptions(source: Source.serverAndCache));


        Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
        UserModel user = UserModel.fromJson(userData!);
        user.totalSalary = 0;
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'totalSalary': currentTotalSalary- int.parse(salaryPaid!)});
        FirebaseFirestore.instance
            .collection('admins')
            .doc( FirebaseAuth.instance.currentUser?.uid)
            .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
          if (value.exists) {
//add number of sessions to it
            FirebaseFirestore.instance
                .collection('admins')
                .doc( FirebaseAuth.instance.currentUser?.uid)
                .collection('dates')
                .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                .update({
              //totalSalary
              'totalSalary': FieldValue.increment(int.parse(salaryPaid!)),
             // 'totalHours': FieldValue.increment(-totalHours),
            });
          } else {
            //create new document and add number of sessions to it
            FirebaseFirestore.instance
                .collection('admins')
                .doc( FirebaseAuth.instance.currentUser?.uid)
                .collection('dates')
                .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                .set({
              //totalSalary
              'totalSalary': int.parse(salaryPaid!),
            //  'totalHours': 0,
            });
          }
        });
        print('Total salary of all users: $globalTotalSalary');
        //  showToast(
        //      state: ToastStates.SUCCESS,
        //       msg: //pay salary success
        //       'تم صرف المرتب بنجاح',
        //     );
        showRollbackButton = true;
        //delay 5 seconds
        Timer(Duration(seconds: 5), () {
          showRollbackButton = false;
          emit(ShowRollbackButtonState());
        });
        NotificationModel notification = NotificationModel(
          message: 'تم صرف المرتب للمستخدم ${user.name} بمبلغ ${salaryPaid} جنيه',
          timestamp: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('admins')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .add(notification.toMap());
        salaryController.clear();
        emit(PaySalarySuccessStateWithoutInternet());
        return;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(GetOptions(source: Source.server));

      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        this.currentTotalSalary = userData['totalSalary'] ?? 0;
        int newTotalSalary = 0;

        // Only update the user's total salary if it has changed
        if (currentTotalSalary != newTotalSalary) {
          // Save the current total salary locally before updating it
          saveSalaryLocally(userId, currentTotalSalary!);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'totalSalary': currentTotalSalary- int.parse(salaryPaid!)});

          // Update the user in the users list
          UserModel updatedUser = UserModel.fromJson(userData);
          updatedUser.totalSalary = newTotalSalary;
          //  int userIndex = coaches.indexWhere((user) => user.uId == userId);
          //   if (userIndex != -1) {
          //     coaches[userIndex] = updatedUser;
          //    }

          // Show elevated button if user wants to rollback this action
          showRollbackButton = true;
          //delay 5 seconds
          Timer(Duration(seconds: 5), () {
            showRollbackButton = false;
            emit(ShowRollbackButtonState());
          });
          FirebaseFirestore.instance
              .collection('admins')
              .doc( FirebaseAuth.instance.currentUser?.uid)
              .collection('dates').doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}').get().then((value) {
            if (value.exists) {
//add number of sessions to it
              FirebaseFirestore.instance
                  .collection('admins')
                  .doc( FirebaseAuth.instance.currentUser?.uid)
                  .collection('dates')
                  .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                  .update({
                //totalSalary
                'totalSalary': FieldValue.increment(int.parse(salaryPaid!)),
                // 'totalHours': FieldValue.increment(-totalHours),
              });
            } else {
              //create new document and add number of sessions to it
              FirebaseFirestore.instance
                  .collection('admins')
                  .doc( FirebaseAuth.instance.currentUser?.uid)
                  .collection('dates')
                  .doc('${DateTime.now().month.toString()}-${DateTime.now().year.toString()}')
                  .set({
                //totalSalary
                'totalSalary': int.parse(salaryPaid!),
                //  'totalHours': 0,
              });
            }
          });
          NotificationModel notification = NotificationModel(
            message: 'تم صرف المرتب للمستخدم $userName بمبلغ $salaryPaid جنيه',
            timestamp: DateTime.now(),
          );
          FirebaseFirestore.instance
              .collection('admins')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('notifications')
              .add(notification.toMap());
          salaryController.clear();

          // showToast(
          //   state: ToastStates.SUCCESS,
          //   msg: //pay salary success
          //   'تم صرف المرتب بنجاح',
          // );
          emit(PaySalarySuccessState());
        } else {
          //emit(PaySalarySuccessStateWithoutUpdate());
        }
      } else {
        throw 'User data not found';
      }
    } catch (error) {
      print(error.toString());
      emit(PaySalaryErrorState(error.toString()));
    }
  }
  Future<void> payBonus({String? userId, String? salaryPaid,
  required int TotalSalary
  }) async {
    try {
      latestUserId = userId;
      print('userId: $userId');

      currentTotalSalary = TotalSalary;
      print('currentTotalSalary: $currentTotalSalary');

      print('userId: $userId');
      emit(PaySalaryLoadingState());
      bool isConnected = await checkInternetConnectivity();
      if (!isConnected) {
        print('latestUserId: $latestUserId');
        print('currentTotalSalary: $currentTotalSalary');
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(GetOptions(source: Source.serverAndCache));
        Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

        UserModel user = UserModel.fromJson(userData!);
        user.totalSalary = user.totalSalary! + int.parse(salaryPaid!);
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'totalSalary': user.totalSalary});

        print('Total salary of all users: $globalTotalSalary');
        NotificationModel notification = NotificationModel(
          message: 'تم صرف المكافأة للمستخدم ${user.name} بمبلغ ${salaryPaid} جنيه',
          timestamp: DateTime.now(),
        );
        FirebaseFirestore.instance
            .collection('admins')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('notifications')
            .add(notification.toMap());
        salaryController.clear();
      //  showToast(
      //    state: ToastStates.SUCCESS,
      //    msg: 'تم صرف المرتب بنجاح '
      //        'سيتم تحديث البيانات عند توفر الإنترنت',
      //  );
        // Enable rollback button
        showRollbackButton = true;
        Timer(Duration(seconds: 5), () {
          showRollbackButton = false;
          emit(ShowRollbackButtonState());
        });

        emit(PaySalarySuccessStateWithoutInternet());
        return;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(GetOptions(source: Source.serverAndCache));

      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      int? totalSalary = userData?['totalSalary'];
      int? salary14 = int.parse(salaryPaid!);
      int? newTotalSalary = totalSalary! + salary14!;
      print('newTotalSalary: $newTotalSalary');

      // Store the current total salary for rollback
      currentTotalSalary = totalSalary;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'totalSalary': newTotalSalary});
      // Update the user in the users list
     // int userIndex = coaches.indexWhere((user) => user.uId == userId);
    //  if (userIndex != -1) {
    //    coaches[userIndex].totalSalary = newTotalSalary;
    //  }
      NotificationModel notification = NotificationModel(
        message: 'تم صرف المكافأة للمستخدم ${userData!['name']} بمبلغ $salaryPaid جنيه',
        timestamp: DateTime.now(),
      );
      FirebaseFirestore.instance
          .collection('admins')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notifications')
          .add(notification.toMap());
      salaryController.clear();
      //show toast message
     // showToast(
    //    state: ToastStates.SUCCESS,
   //     msg: 'تم صرف المرتب بنجاح',
  //    );

      // Enable rollback button
      showRollbackButton = true;
      Timer(Duration(seconds: 5), () {
        showRollbackButton = false;
        emit(ShowRollbackButtonState());
      });

      emit(PaySalarySuccessState());
    } catch (error) {
      print(error.toString());
      emit(PaySalaryErrorState(error.toString()));
    }
  }

  Future<void> rollbackPartialSalary() async {
    try {
      bool isConnected = await checkInternetConnectivity();
      if (!isConnected) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(latestUserId)
            .get(GetOptions(source: Source.serverAndCache));
        Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

        UserModel user = UserModel.fromJson(userData!);
        user.totalSalary = currentTotalSalary;
        FirebaseFirestore.instance
            .collection('users')
            .doc(latestUserId)
            .update({'totalSalary': user.totalSalary});

        showToast(
          state: ToastStates.SUCCESS,
          msg: 'تم التراجع عن العملية '
              'سيتم تحديث البيانات عند توفر الإنترنت',
        );
        emit(RollbackSalarySuccessStateWithoutInternet());
        return;
      }

      print('latestUserId: $latestUserId');
      print('currentTotalSalary: $currentTotalSalary');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(latestUserId)
          .update({'totalSalary': currentTotalSalary});

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(latestUserId)
          .get(GetOptions(source: Source.server));

      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      UserModel updatedUser = UserModel.fromJson(userData!);
      updatedUser.totalSalary = currentTotalSalary;
    //  int userIndex = coaches.indexWhere((user) => user.uId == latestUserId);
    //  if (userIndex != -1) {
   //     coaches[userIndex] = updatedUser;
   //   }

      showToast(
        state: ToastStates.SUCCESS,
        msg: 'تم التراجع عن العملية',
      );
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void>rollbackSession() async {
    try {
      bool isConnected = await checkInternetConnectivity();
      if (!isConnected) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(latestUserId)
            .get(GetOptions(source: Source.serverAndCache));
        Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

        UserModel user = UserModel.fromJson(userData!);
        user.numberOfSessions = currentNumberOfSessions;
        FirebaseFirestore.instance
            .collection('users')
            .doc(latestUserId)
            .update({'numberOfSessions': user.numberOfSessions});

        showToast(
          state: ToastStates.SUCCESS,
          msg: 'تم التراجع عن العملية '
              'سيتم تحديث البيانات عند توفر الإنترنت',
        );
        emit(RollbackSalarySuccessStateWithoutInternet());
        return;
      }
      print('latestUserId: $latestUserId');
      print('currentTotalSalary: $currentTotalSalary');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(latestUserId)
          .update({'numberOfSessions': currentNumberOfSessions});
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(latestUserId)
          .get(GetOptions(source: Source.server));

      Map<String, dynamic>? userData =
      userSnapshot.data() as Map<String, dynamic>?;

      UserModel updatedUser = UserModel.fromJson(userData!);
      updatedUser.numberOfSessions = currentNumberOfSessions;
 //     int userIndex = coaches.indexWhere((user) => user.uId == latestUserId);
//      if (userIndex != -1) {
//        coaches[userIndex] = updatedUser;
//      }

      showToast(
        state: ToastStates.SUCCESS,
        msg: 'تم التراجع عن العملية',
      );
    } catch (error) {
      print(error.toString());
    }
  }
  Future<void> updateShowRollbackButtonSession(
      ) async {
    emit(UpdateShowRollbackButtonLoadingState());
    showRollbackButton = false;
    emit(UpdateShowRollbackButtonSuccessState());
  }

  int? selectedBranchIndex = 0;
  void changeSelectedBranchIndex(int index) {
    selectedBranchIndex = index;
    emit(ChangeSelectedBranchIndexState(
   //   selectedBranchIndex,
    ));
  }

   //getBranches() {}
  List<BranchModel> branches = [];
  Future<void> getBranches() async {
    //print all branches now in loop
    print('branches.length\n\n\n\n\n\n');
    print(branches.length);
    emit(GetBranchesLoadingState());
    FirebaseFirestore.instance
        .collection('branches')
        .get(const GetOptions(source: Source.serverAndCache))
        .then((value) {
      value.docs.forEach((element) {
        branches.add(BranchModel.fromJson(element.data()));
      });
      print('after branches.length\n\n\n\n\n\n');
      print(branches.length);
      emit(GetBranchesSuccessState(
        branches,
      ));
    }).catchError((error) {
      print(error.toString());
      emit(GetBranchesErrorState(error.toString()));
    });
  }


  void deleteGroup({
    required String groupId,
    required String branchId,
    required List<String> schedulesIds,
    required List<String> schedulesDays,
    context,
  }) async {
   // bool isConnected = checkInternetConnectivity();
    emit(DeleteGroupLoadingState());
 //debug parameters
    print('groupId: $groupId');
    print('branchId: $branchId');
    print('schedulesIds: $schedulesIds');
    print('schedulesDays: $schedulesDays');
     //if (!isConnected) {
    //   FirebaseFirestore.instance
    //       .collection('branches')
    //       .doc(branchId)
    //       .collection('groups')
    //       .doc(groupId)
    //       .delete();
    //
    //   showToast(
    //     state: ToastStates.ERROR,
    //     msg: 'Group deleted. Data will be updated when internet connection is available.',
    //   );
    //
    //   emit(DeleteGroupErrorState('No internet connection'));
    //   return;
    // }

    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Delete each schedule document in the batch
    for (int i = 0; i < schedulesIds.length; i++) {
      DocumentReference scheduleRef = FirebaseFirestore.instance
          .collection('admins')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('schedules')
          .doc(schedulesDays[i])
          .collection('schedules')
          .doc(schedulesIds[i]);


      // Delete the subcollection of users inside the schedule
      CollectionReference usersRef = scheduleRef.collection('users');
      QuerySnapshot usersSnapshot = await usersRef.get();
      List<DocumentSnapshot> usersDocs = usersSnapshot.docs;
      for (DocumentSnapshot userDoc in usersDocs) {
        batch.delete(userDoc.reference);
      }

      batch.delete(scheduleRef);
    }

    // Delete the group document in the batch
    DocumentReference groupRef = FirebaseFirestore.instance
        .collection('branches')
        .doc(branchId)
        .collection('groups')
        .doc(groupId);

    batch.delete(groupRef);

 //   try {
      // Commit the batch operation
       batch.commit();

      print('Group deleted');

      // Show toast message
     // showToast(
    //    state: ToastStates.SUCCESS,
   //     msg: //'Group deleted', in arabic
   //     'تم حذف المجموعة',
   //   );
      //pop
    emit(DeleteGroupSuccessState());
    Navigator.pop(context);


    //}
    // catch (error) {
    //   print('Failed to delete group: $error');
    //   showToast(msg: 'Failed to delete group', state: ToastStates.ERROR);
    //   emit(DeleteGroupErrorState(error.toString()));
    // }
  }

//                     ManageSalaryCubit.get(context).deleteSchedule(
// scheduleId: scheduleId,
// );
//make function to delete schedule from firebase
}
