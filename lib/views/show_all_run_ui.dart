// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_tracker_app/models/run.dart';
import 'package:flutter_tracker_app/services/supabase_services.dart';
import 'package:flutter_tracker_app/views/add_run_ui.dart';
import 'package:flutter_tracker_app/views/update_delete_ui.dart';

class ShowAllRunUI extends StatefulWidget {
  const ShowAllRunUI({super.key});

  @override
  State<ShowAllRunUI> createState() => _ShowAllRunUIState();
}

class _ShowAllRunUIState extends State<ShowAllRunUI> {
  //สร้างตัวแปรเก็บข้อมูลทั้งหมดที่ไปดึงมาจาก Supabase
  List<Run>? runData;

  //สร้างคำสั่งเพื่อดึงข้อมูลจาก Supabase มาเก็บในตัวแปร runData ผ่านทาง SupabaseService
  Future<void> fetchRunData() async {
    final data = await SupabaseService().getAllRuns();

    setState(() {
      runData = data;
    });
  }

  @override
  void initState() {
    //เรียกใช้คำสั่งเพื่อดึงข้อมูลตอนหน้าจอถูกเปิด
    fetchRunData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนของ appBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 1, 80),
        title: Text(
          'Run Tracker',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      // ส่วนของ floatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // เปิดไป AddRunUI() แบบย้อนกลับได้
          await Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => AddRunUI(),
              builder: (context) => AddRunUI(),
            ),
          );

          //เรียกให้ดึงข้อมูลใหม่มาอีกรอบ
          fetchRunData();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 5, 1, 80),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ส่วนของ body
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.355,
              height: MediaQuery.of(context).size.width * 0.355,
              fit: BoxFit.cover,
            ),
            Text(
              'วิ่งกันเถอะ',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.0325,
                fontWeight: FontWeight.bold,
              ),
            ),
            // ต่อไปเป็นของแสดงข้อมูลการวิ่งที่ดึงมาจาก Supabase
            // เครื่องหมาย ?? เรียกว่า is-null operator
            Expanded(
              child: ListView.separated(
                  itemCount: runData?.length ?? 0,
                  separatorBuilder: (context, index) =>
                      Divider(indent: 20, endIndent: 20),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: ListTile(
                        onTap: () async {
                          //เปิดไปหน้าจอ UpdateDeleteRunUI() แบบย้อนกลับได้
                          //โดยที่ต้องส่งข้อมูลไปด้วย และพอย้อนกลับมาต้องไปดึงข้อมูลมาใหม่
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateDeleteRunUI(
                                  runDataDetail: runData![index]),
                            ),
                          );

                          //กลับมาแล้วไปดึงข้อมูลมาใหม่
                          fetchRunData();
                        },
                        tileColor:
                            index % 2 == 0 ? Colors.red[100] : Colors.blue[100],
                        title: Text(
                          // "วิ่งที่ไหน: " + runData![index].runWhere!,
                          "วิ่งที่ไหน: ${runData![index].runWhere!}",
                        ),
                        subtitle: Text(
                          "วิ่งไป: ${runData![index].runDistance!} กม.",
                        ),
                        trailing: Icon(
                          Icons.info,
                          color: Colors.red,
                        ),
                        leading: runData![index].runImageUrl! == ''
                            ? Image.asset(
                                'assets/images/logo.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                runData![index].runImageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
