/**
* Name: Main
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Main

/* Insert your model definition here */

import "./Parameters.gaml"
import "./Intersection.gaml"
import "./NormalCar.gaml"
import "./Road.gaml"
import "./Vehicle.gaml"
import "./Pedestrian.gaml"
import "./PedestrianPath.gaml"
import "./Administrator.gaml"

global {

//	float seed <- 0.488249722206318;
	
	file inputParameter; //OACIS用インプットパラメータの変数
	string pathWorkDirectory<-".";//OACIS用ワークディレクトリの場所を保存する
	int num <- 0; //重みを入れるための計算用
	float per_cycle; //何サイクルごとに車を発生させるか　nilのときは発生しない
	float per_cycle_1;
	float per_cycle_2;
	float per_cycle_3;
	float per_cycle_4;
	float per_cycle_5;
	float per_cycle_6;
	float per_cycle_7;
	float per_cycle_8;
	float per_cycle_9;
	float per_cycle_10;
	float per_cycle_11;
	float per_cycle_12;
	float per_cycle_13;
	float per_cycle_14;
	float per_cycle_15;
	float per_cycle_16;
	float per_cycle_random;
	float per_cycle_dummy;
	
	int to_per_cycle_1;
	int to_per_cycle_2;
	int to_per_cycle_3;
	int to_per_cycle_4;
	int to_per_cycle_5;
	int to_per_cycle_6;
	int to_per_cycle_7;
	int to_per_cycle_8;
	int to_per_cycle_9;
	int to_per_cycle_10;
	int to_per_cycle_11;
	int to_per_cycle_12;
	int to_per_cycle_13;
	int to_per_cycle_14;
	int to_per_cycle_15;
	int to_per_cycle_16;
	
	list<int> to_per_cycle_list <- [];
	
//	int car_num <- 10200; //シミュレーション全体で発生する車の数
	
	//ダミー時は桜通補正用に以下を使用
//	int car_num <- 9200;
	int car_for_dummy <- 2000;
	int car_num <- 11200;
	int finish_cycle <- 14400; //シミュレーションを終了するサイクル　12時間分なら43200サイクル
	
	float weight_value_1;
	float weight_value_2;
	float weight_value_3;
	float weight_value_4;
	float weight_value_5;
	float weight_value_6;
	float weight_value_7;
	float weight_value_8;
	float weight_value_9;
	float weight_value_10;
	float weight_value_11;
	float weight_value_12;
	float weight_value_13;
	float weight_value_14;
	float weight_value_15;
	float weight_value_16;
	float weight_value_17;
	float weight_value_18;
	float weight_value_19;
	float weight_value_20;
	float weight_value_21;
	float weight_value_22;
	
	list<float> weight_value_list <- [];
	
	string o_ga;//ダミーに合わせる際のGAで調整するoのint列受け取るとき用。stringなのはintにすると先頭が0だと怒られるから
	list<int> list_o_ga <- []; //受け取ったものをリストに直したもの
	list<int> o_to_1 <- []; //1に向かうoの場所をGAによって決めて確率分入れる（one_ofでこの中から抽出）
	list<int> o_to_2 <- [];
	list<int> o_to_3 <- [];
	list<int> o_to_4 <- [];
	list<int> o_to_5 <- [];
	list<int> o_to_6 <- [];
	list<int> o_to_7 <- [];
	list<int> o_to_8 <- [];
	list<int> o_to_9 <- [];
	list<int> o_to_10 <- [];
	list<int> o_to_11 <- [];
	list<int> o_to_12 <- [];
	list<int> o_to_13 <- [];
	list<int> o_to_14 <- [];
	list<int> o_to_15 <- [];
	list<int> o_to_16 <- [];
	
	//データ利用数を認識
	int place_num <- nil;
	
	//データ使用場所を認識（今回はDに使われる）
	int place_1;
	int place_2;
	int place_3;
	int place_4;
	int place_5;
	int place_6;
	int place_7;
	int place_8;
	int place_9;
	int place_10;
	
	//GA_data用
	list<int> other_d_list <- [];
	
	int other_d_1;
	int other_d_2;
	int other_d_3;
	int other_d_4;
	int other_d_5;
	int other_d_6;
	int other_d_7;
	int other_d_8;
	int other_d_9;
	int other_d_10;
	int other_d_11;
	int other_d_12;
	int other_d_13;
	int other_d_14;
	int other_d_15;
	int other_d_16;

	
	
	//GA_data用　すべての読みこんだplace_1,place_2の番号を格納リスト
	list<int> place_list <- [];
	
	//GA_data用　計算していないper_cycleを格納
	map<string,float> per_cycle_list;
	
	map<agent,float> weights_default;
	
	list<agent> west_area_inter <- []; //行動を調整するための左上に位置するインター
	
	list<int> up_left_left <- [424,426,429]; //それぞれ交差点のid
	list<int> up_left_right <- [430,431,432]; //それぞれ交差点のid
	
	list<int> up_left <- [424,426,429,430,431,432]; //1kkkkkkkkkkkkkkkkkkkk
	
	list<int> up_right <- [433,434,435,436,437,438,439,440,441,442]; //それぞれ交差点のid //1kkkkkkkkkkkkkkkkkkkk
	list<int> down_left_left <- [477,476,475,474,473,472,471]; //それぞれ交差点のid
	list<int> down_left_right <- [470,469,468,467,466]; //それぞれ交差点のid
	
	list<int> down_left <- [477,476,475,474,473,472,471,470,469,468,467,466]; //1kkkkkkkkkkkkkkkkkkkk
	
	list<int> down_right <- [483,463,462,461,460,459,458,457,456,455,454]; //それぞれ交差点のid //1kkkkkkkkkkkkkkkkkkkk

	list<int> left_up_up <- [425,68]; //それぞれ交差点のid
	list<int> left_up_down <- [482]; //それぞれ交差点のid
	list<int> left_down_up <- [480,481]; //それぞれ交差点のid
	
	list<int> left <- [480,481,482,478,479,477]; //1kkkkkkkkkkkkkkkkkkkk
	
	list<int> left_down_down <- [478]; //それぞれ交差点のid
	list<int> right_up <- [443,444,445,446,447,448]; //それぞれ交差点のid
	list<int> right_down <- [449,450,452,453]; //それぞれ交差点のid
	
	list<int> right <- [443,444,445,446,447,448,449,450,452,453]; //kkkkkkkkkkkkkkkkk
	
	list<int> top_left <- [425,68,482]; //それぞれ交差点のid
	list<int> bottom_right <- [478,479,483,463,462,461,460,459,458,457,456,455,454,449,450,452,453]; //それぞれ交差点のid
	
	list<int> end_point <- [470,469,468,477,476,475,474,473,472,471,481,443,444,445,446,447,433,434,436,437,438,439,440,441,442,425,68,483,462,461,460,459,456,455,454,449,450]; //それぞれ交差点のid
	
	
	int difference; //集計した結果との差
	
	//今回使用するodリスト
	list<int> inter1_west <- [479,481];
	list<int> inter1_east <- [123,135];
	
	list<int> inter3_north <- [434,437,438,439];
	list<int> inter3_south <- [476,474,472,471,468,465,464];
	
	list<int> inter4_north <- [426,428];
	list<int> inter4_south <- [454,455,457,458,459,460,461];
	
	int loop_counter;
	
	//ACO用の生成台数管理
	list<int> aco_cycle_list;
	
	//ACOで、出発地点となるinterのペア
	list<pair<intersection,intersection>> aco_inter_list;
	
	//ACOでスタート地点の道路の生成台数を管理
	list<int> aco_start_road_cycle;
	
	//ACO終了判定に使用
//	list<int> aco_checkpoint_list <- [46,16,179,4,463,198,80,184]; //2，3個離れてるやつ
	list<int> aco_checkpoint_list <- [281,17,256,149,463,361,82,52]; //2，3個離れてるやつ
	
	list<float> prob_load_list <- []; //GA受け取り用変数各計測地点interの確率に従う重みリスト
	
	
	
	init {
		
	}
	reflex  when:every(per_cycle_1#cycle){
		create normal_car number:1 with:[born_timing::"1"];
	}
	
	reflex create_car_2 when:every(per_cycle_2#cycle){
		create normal_car number:1 with:[born_timing::"2"];
	}
	
	reflex create_car_3 when:every(per_cycle_3#cycle){
		create normal_car number:1 with:[born_timing::"3"];
	}
	
	reflex create_car_4 when:every(per_cycle_4#cycle){
		create normal_car number:1 with:[born_timing::"4"];
	}
	
	reflex create_car_5 when:every(per_cycle_5#cycle){
		create normal_car number:1 with:[born_timing::"5"];
	}
	
	reflex create_car_6 when:every(per_cycle_6#cycle){
		create normal_car number:1 with:[born_timing::"6"];
	}
	
	reflex create_car_7 when:every(per_cycle_7#cycle){
		create normal_car number:1 with:[born_timing::"7"];
	}
	
	reflex create_car_8 when:every(per_cycle_8#cycle){
		create normal_car number:1 with:[born_timing::"8"];
	}
	
	reflex create_car_9 when:every(per_cycle_9#cycle){
		create normal_car number:1 with:[born_timing::"9"];
	}
	
	reflex create_car_10 when:every(per_cycle_10#cycle){
		create normal_car number:1 with:[born_timing::"10"];
	}
	
	reflex create_car_11 when:every(per_cycle_11#cycle){
		create normal_car number:1 with:[born_timing::"11"];
	}
	
	reflex create_car_12 when:every(per_cycle_12#cycle){
		create normal_car number:1 with:[born_timing::"12"];
	}
	
	reflex create_car_13 when:every(per_cycle_13#cycle){
		create normal_car number:1 with:[born_timing::"13"];
	}
	
	reflex create_car_14 when:every(per_cycle_14#cycle){
		create normal_car number:1 with:[born_timing::"14"];
	}
	
	reflex create_car_15 when:every(per_cycle_15#cycle){
		create normal_car number:1 with:[born_timing::"15"];
	}
	
	reflex create_car_16 when:every(per_cycle_16#cycle){
		create normal_car number:1 with:[born_timing::"16"];
	}
	
//	reflex test_per when:every(100#cycle) {
//		create normal_car number:1 with:[born_timing::"test"];
//	}
//	
//	reflex random when:every((finish_cycle / car_num)#cycle){
//		create normal_car number:1 with:[born_timing::"random"];
//	}
//	
//	reflex dummy when:every(per_cycle_dummy#cycle){
//		create normal_car number:1 with:[born_timing::"dummy"];
//	}

}

species building schedules:[]{
	int areano;
	init {

	}
}

species water schedules:[]{
	
}

species rail schedules:[]{
	rgb color <- #brown;
}

species north_west_area schedules:[]{
	init {	
		ask intersection where(each.id != 427 and each.id != 428 and each.id != 69){
			if self distance_to myself = 0{
				add self to: west_area_inter;
			}
		}
	}
}

experiment Driving type:gui{
	float minimum_cycle_dulation <- 0.1;
	output{
		display show_sim type:opengl{
			species road  refresh:false;
			species normal_car;
			species building refresh:false;
			species water refresh:false;
			species rail refresh:false;
			species pedestrian;
			species pedestrian_path refresh:false;
			species intersection refresh:false;
			
			overlay position: {0,0} size: {150,70} background: #gray transparency: 0.2 border: #black rounded: true {
				draw string(current_date.hour) + ":" + string(current_date.minute) + ":" + string(current_date.second) font: font("Helvetica", 20, #bold) at: {5,40} color: #white;
			}
		}
	}
}

experiment Headless_test type:gui{
//	float seed <- 0.9738391130520201;
	parameter "pathWorkDirectory" var:pathWorkDirectory type:string;

	init {		
		inputParameter <- json_file(pathWorkDirectory + "/_input.json");		

//		//そのDを決めたあと、そこに向かうOの選択確率
		o_ga <- string(inputParameter["o_list_string"]);
        
//		o_ga <- ("2301021301223213001331122023112203013023030310130321322310002322112001033132103301301213012200131102303030323232032031");
//		o_ga <- ("031003123321032302113320023123203313132033003220322230132133112301230310321213301213230032313203312013331203031033023212233132112031231032323032313012033210");
		

//		//prob_load_listに計測（重みに確率を寄与させる）地点分代入
		add int(inputParameter["prob_load_1"]) to:prob_load_list;
		add int(inputParameter["prob_load_2"]) to:prob_load_list;
		add int(inputParameter["prob_load_3"]) to:prob_load_list;
		add int(inputParameter["prob_load_4"]) to:prob_load_list;
		add int(inputParameter["prob_load_5"]) to:prob_load_list;
		add int(inputParameter["prob_load_6"]) to:prob_load_list;
		add int(inputParameter["prob_load_7"]) to:prob_load_list;

		to_per_cycle_1 <- int(inputParameter["to_per_cycle_1"]);
		to_per_cycle_2 <- int(inputParameter["to_per_cycle_2"]);
		to_per_cycle_3 <- int(inputParameter["to_per_cycle_3"]);
		to_per_cycle_4 <- int(inputParameter["to_per_cycle_4"]);
		to_per_cycle_5 <- int(inputParameter["to_per_cycle_5"]);
		to_per_cycle_6 <- int(inputParameter["to_per_cycle_6"]);
		to_per_cycle_7 <- int(inputParameter["to_per_cycle_7"]);
		to_per_cycle_8 <- int(inputParameter["to_per_cycle_8"]);
		to_per_cycle_9 <- int(inputParameter["to_per_cycle_9"]);
		to_per_cycle_10 <- int(inputParameter["to_per_cycle_10"]);
		to_per_cycle_11 <- int(inputParameter["to_per_cycle_11"]);
		to_per_cycle_12 <- int(inputParameter["to_per_cycle_12"]);
		to_per_cycle_13 <- int(inputParameter["to_per_cycle_13"]);
		to_per_cycle_14 <- int(inputParameter["to_per_cycle_14"]);
		to_per_cycle_15 <- int(inputParameter["to_per_cycle_15"]);
		to_per_cycle_16 <- int(inputParameter["to_per_cycle_16"]);
		
		
		
//		受け取ったstringをlistに変換
		loop i from: 0 to: length(o_ga) - 1 { // 文字列の最初から最後までループ
		    add int(o_ga at i) to: list_o_ga; // 各文字をリストに追加
		}
		
		loop j over:list_o_ga {
			if 0 <= j and j <= 7 { //1
				if j = 0 {
					loop k from: 0 to: j {
						add 1  to:o_to_1;
					}					
				} else if j = 1 {
					loop k from: 0 to: j {
						add 2  to:o_to_1;
					}
				} else if j = 2 {
					loop k from: 0 to: j {
						add 3  to:o_to_1;
					}
				} else if j = 3 {
					loop k from: 0 to: j {
						add 4  to:o_to_1;
					}
				} else if j = 4 {
					loop k from: 0 to: j {
						add 5  to:o_to_1;
					}
				} else if j = 5 {
					loop k from: 0 to: j {
						add 6  to:o_to_1;
					}
				} else if j = 6 {
					loop k from: 0 to: j {
						add 7  to:o_to_1;
					}
				}else {
					loop k from: 0 to: j {
						add 8  to:o_to_1;
					}
				}
			} else if 8 <= j and j <= 15 { //2
				if j = 8 {
					loop k from: 0 to: j {
						add 1  to:o_to_2;
					}					
				} else if j = 9 {
					loop k from: 0 to: j {
						add 2  to:o_to_2;
					}
				} else if j = 10 {
					loop k from: 0 to: j {
						add 3  to:o_to_2;
					}
				} else if j = 11 {
					loop k from: 0 to: j {
						add 4  to:o_to_2;
					}
				} else if j = 12 {
					loop k from: 0 to: j {
						add 5  to:o_to_2;
					}
				} else if j = 13 {
					loop k from: 0 to: j {
						add 6  to:o_to_2;
					}
				} else if j = 14 {
					loop k from: 0 to: j {
						add 7  to:o_to_2;
					}
				}else {
					loop k from: 0 to: j {
						add 8  to:o_to_2;
					}
				}
			} else if 16 <= j and j <= 23 { //3
				if j = 16 {
					loop k from: 0 to: j {
						add 1  to:o_to_3;
					}					
				} else if j = 17 {
					loop k from: 0 to: j {
						add 2  to:o_to_3;
					}
				} else if j = 18 {
					loop k from: 0 to: j {
						add 3  to:o_to_3;
					}
				} else if j = 19 {
					loop k from: 0 to: j {
						add 4  to:o_to_3;
					}
				} else if j = 20 {
					loop k from: 0 to: j {
						add 5  to:o_to_3;
					}
				} else if j = 21 {
					loop k from: 0 to: j {
						add 6  to:o_to_3;
					}
				} else if j = 22 {
					loop k from: 0 to: j {
						add 7  to:o_to_3;
					}
				}else {
					loop k from: 0 to: j {
						add 8  to:o_to_3;
					}
				}
			} else if 24 <= j and j <= 30 { //4
				if j = 24 {
					loop k from: 0 to: j {
						add 1  to:o_to_4;
					}					
				} else if j = 25 {
					loop k from: 0 to: j {
						add 2  to:o_to_4;
					}
				} else if j = 26 {
					loop k from: 0 to: j {
						add 3  to:o_to_4;
					}
				} else if j = 27 {
					loop k from: 0 to: j {
						add 4  to:o_to_4;
					}
				} else if j = 28 {
					loop k from: 0 to: j {
						add 5  to:o_to_4;
					}
				} else if j = 29 {
					loop k from: 0 to: j {
						add 6  to:o_to_4;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_4;
					}
				}
			} else if 31 <= j and j <= 37 { //5
				if j = 31 {
					loop k from: 0 to: j {
						add 1  to:o_to_5;
					}					
				} else if j = 32 {
					loop k from: 0 to: j {
						add 2  to:o_to_5;
					}
				} else if j = 33 {
					loop k from: 0 to: j {
						add 3  to:o_to_5;
					}
				} else if j = 34 {
					loop k from: 0 to: j {
						add 4  to:o_to_5;
					}
				} else if j = 35 {
					loop k from: 0 to: j {
						add 5  to:o_to_5;
					}
				} else if j = 36 {
					loop k from: 0 to: j {
						add 6  to:o_to_5;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_5;
					}
				}
			} else if 38 <= j and j <= 44 { //6
				if j = 38 {
					loop k from: 0 to: j {
						add 1  to:o_to_6;
					}					
				} else if j = 39 {
					loop k from: 0 to: j {
						add 2  to:o_to_6;
					}
				} else if j = 40 {
					loop k from: 0 to: j {
						add 3  to:o_to_6;
					}
				} else if j = 41 {
					loop k from: 0 to: j {
						add 4  to:o_to_6;
					}
				} else if j = 42 {
					loop k from: 0 to: j {
						add 5  to:o_to_6;
					}
				} else if j = 43 {
					loop k from: 0 to: j {
						add 6  to:o_to_6;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_6;
					}
				}
			} else if 45 <= j and j <= 51 { //7
				if j = 45 {
					loop k from: 0 to: j {
						add 1  to:o_to_7;
					}					
				} else if j = 46 {
					loop k from: 0 to: j {
						add 2  to:o_to_7;
					}
				} else if j = 47 {
					loop k from: 0 to: j {
						add 3  to:o_to_7;
					}
				} else if j = 48 {
					loop k from: 0 to: j {
						add 4  to:o_to_7;
					}
				} else if j = 49 {
					loop k from: 0 to: j {
						add 5  to:o_to_7;
					}
				} else if j = 50 {
					loop k from: 0 to: j {
						add 6  to:o_to_7;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_7;
					}
				}
			} else if 52 <= j and j <= 57 { //8
				if j = 52 {
					loop k from: 0 to: j {
						add 1  to:o_to_8;
					}					
				} else if j = 53 {
					loop k from: 0 to: j {
						add 2  to:o_to_8;
					}
				} else if j = 54 {
					loop k from: 0 to: j {
						add 3  to:o_to_8;
					}
				} else if j = 55 {
					loop k from: 0 to: j {
						add 4  to:o_to_8;
					}
				} else if j = 56 {
					loop k from: 0 to: j {
						add 5  to:o_to_8;
					}
				} else {
					loop k from: 0 to: j {
						add 6  to:o_to_8;
					}
				}
			} else if 58 <= j and j <= 63 { //9
				if j = 58 {
					loop k from: 0 to: j {
						add 1  to:o_to_9;
					}					
				} else if j = 59 {
					loop k from: 0 to: j {
						add 2  to:o_to_9;
					}
				} else if j = 60 {
					loop k from: 0 to: j {
						add 3  to:o_to_9;
					}
				} else if j = 61 {
					loop k from: 0 to: j {
						add 4  to:o_to_9;
					}
				} else if j = 62 {
					loop k from: 0 to: j {
						add 5  to:o_to_9;
					}
				} else {
					loop k from: 0 to: j {
						add 6  to:o_to_9;
					}
				}
			} else if 64 <= j and j <= 69 { //10
				if j = 64 {
					loop k from: 0 to: j {
						add 1  to:o_to_10;
					}					
				} else if j = 65 {
					loop k from: 0 to: j {
						add 2  to:o_to_10;
					}
				} else if j = 66 {
					loop k from: 0 to: j {
						add 3  to:o_to_10;
					}
				} else if j = 67 {
					loop k from: 0 to: j {
						add 4  to:o_to_10;
					}
				} else if j = 68 {
					loop k from: 0 to: j {
						add 5  to:o_to_10;
					}
				} else {
					loop k from: 0 to: j {
						add 6  to:o_to_10;
					}
				}
			} else if 70 <= j and j <= 75 { //11
				if j = 70 {
					loop k from: 0 to: j {
						add 1  to:o_to_11;
					}					
				} else if j = 71 {
					loop k from: 0 to: j {
						add 2  to:o_to_11;
					}
				} else if j = 72 {
					loop k from: 0 to: j {
						add 3  to:o_to_11;
					}
				} else if j = 73 {
					loop k from: 0 to: j {
						add 4  to:o_to_11;
					}
				} else if j = 74 {
					loop k from: 0 to: j {
						add 5  to:o_to_11;
					}
				} else {
					loop k from: 0 to: j {
						add 6  to:o_to_11;
					}
				}
			} else if 76 <= j and j <= 82 { //12
				if j = 76 {
					loop k from: 0 to: j {
						add 1  to:o_to_12;
					}					
				} else if j = 77 {
					loop k from: 0 to: j {
						add 2  to:o_to_12;
					}
				} else if j = 78 {
					loop k from: 0 to: j {
						add 3  to:o_to_12;
					}
				} else if j = 79 {
					loop k from: 0 to: j {
						add 4  to:o_to_12;
					}
				} else if j = 80 {
					loop k from: 0 to: j {
						add 5  to:o_to_12;
					}
				} else if j = 81 {
					loop k from: 0 to: j {
						add 6  to:o_to_12;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_12;
					}
				}
			} else if 83 <= j and j <= 88 { //13
				if j = 83 {
					loop k from: 0 to: j {
						add 1  to:o_to_13;
					}					
				} else if j = 84 {
					loop k from: 0 to: j {
						add 2  to:o_to_13;
					}
				} else if j = 85 {
					loop k from: 0 to: j {
						add 3  to:o_to_13;
					}
				} else if j = 86 {
					loop k from: 0 to: j {
						add 4  to:o_to_13;
					}
				} else if j = 87 {
					loop k from: 0 to: j {
						add 5  to:o_to_13;
					}
				} else {
					loop k from: 0 to: j {
						add 6  to:o_to_13;
					}
				}
			} else if 89 <= j and j <= 95 { //14
				if j = 89 {
					loop k from: 0 to: j {
						add 1  to:o_to_14;
					}					
				} else if j = 90 {
					loop k from: 0 to: j {
						add 2  to:o_to_14;
					}
				} else if j = 91 {
					loop k from: 0 to: j {
						add 3  to:o_to_14;
					}
				} else if j = 92 {
					loop k from: 0 to: j {
						add 4  to:o_to_14;
					}
				} else if j = 93 {
					loop k from: 0 to: j {
						add 5  to:o_to_14;
					}
				} else if j = 94 {
					loop k from: 0 to: j {
						add 6  to:o_to_14;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_14;
					}
				}
			} else if 96 <= j and j <= 102 { //15
				if j = 96 {
					loop k from: 0 to: j {
						add 1  to:o_to_15;
					}					
				} else if j = 97 {
					loop k from: 0 to: j {
						add 2  to:o_to_15;
					}
				} else if j = 98 {
					loop k from: 0 to: j {
						add 3  to:o_to_15;
					}
				} else if j = 99 {
					loop k from: 0 to: j {
						add 4  to:o_to_15;
					}
				} else if j = 100 {
					loop k from: 0 to: j {
						add 5  to:o_to_15;
					}
				} else if j = 101 {
					loop k from: 0 to: j {
						add 6  to:o_to_15;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_15;
					}
				}
			} else if 103 <= j and j <= 109 { //16
				if j = 103 {
					loop k from: 0 to: j {
						add 1  to:o_to_16;
					}					
				} else if j = 104 {
					loop k from: 0 to: j {
						add 2  to:o_to_16;
					}
				} else if j = 105 {
					loop k from: 0 to: j {
						add 3  to:o_to_16;
					}
				} else if j = 106 {
					loop k from: 0 to: j {
						add 4  to:o_to_16;
					}
				} else if j = 107 {
					loop k from: 0 to: j {
						add 5  to:o_to_16;
					}
				} else if j = 108 {
					loop k from: 0 to: j {
						add 6  to:o_to_16;
					}
				} else {
					loop k from: 0 to: j {
						add 7  to:o_to_16;
					}
				}
			}
		}

		int num_cycle <- to_per_cycle_1 + to_per_cycle_2 + to_per_cycle_3 + to_per_cycle_4 + to_per_cycle_5 + to_per_cycle_6 + to_per_cycle_7 + to_per_cycle_8 + to_per_cycle_9 + to_per_cycle_10 + to_per_cycle_11 + to_per_cycle_12 + to_per_cycle_13 + to_per_cycle_14 + to_per_cycle_15 + to_per_cycle_16;
		
		if to_per_cycle_1 != 0.0 {
			per_cycle_1 <- finish_cycle / ((to_per_cycle_1 / num_cycle) * car_num);
		} else {
			per_cycle_1 <- nil;
		}
		
		if to_per_cycle_2 != 0.0 {
			per_cycle_2 <- finish_cycle / ((to_per_cycle_2 / num_cycle) * car_num);
		} else {
			per_cycle_2 <- nil;
		}
		
		if to_per_cycle_3 != 0.0 {
			per_cycle_3 <- finish_cycle / ((to_per_cycle_3 / num_cycle) * car_num);
		} else {
			per_cycle_3 <- nil;
		}
		
		if to_per_cycle_4 != 0.0 {
			per_cycle_4 <- finish_cycle / ((to_per_cycle_4 / num_cycle) * car_num);
		} else {
			per_cycle_4 <- nil;
		}
		
		if to_per_cycle_5 != 0.0 {
			per_cycle_5 <- finish_cycle / ((to_per_cycle_5 / num_cycle) * car_num);
		} else {
			per_cycle_5 <- nil;
		}
		
		if to_per_cycle_6 != 0.0 {
			per_cycle_6 <- finish_cycle / ((to_per_cycle_6 / num_cycle) * car_num);
		} else {
			per_cycle_6 <- nil;
		}
		
		if to_per_cycle_7 != 0.0 {
			per_cycle_7 <- finish_cycle / ((to_per_cycle_7 / num_cycle) * car_num);
		} else {
			per_cycle_7 <- nil;
		}
		
		if to_per_cycle_8 != 0.0 {
			per_cycle_8 <- finish_cycle / ((to_per_cycle_8 / num_cycle) * car_num);
		} else {
			per_cycle_8 <- nil;
		}
		
		if to_per_cycle_9 != 0.0 {
			per_cycle_9 <- finish_cycle / ((to_per_cycle_9 / num_cycle) * car_num);
		} else {
			per_cycle_9 <- nil;
		}
		
		if to_per_cycle_10 != 0.0 {
			per_cycle_10 <- finish_cycle / ((to_per_cycle_10 / num_cycle) * car_num);
		} else {
			per_cycle_10 <- nil;
		}
		
		if to_per_cycle_11 != 0.0 {
			per_cycle_11 <- finish_cycle / ((to_per_cycle_11 / num_cycle) * car_num);
		} else {
			per_cycle_11 <- nil;
		}
		
		if to_per_cycle_12 != 0.0 {
			per_cycle_12 <- finish_cycle / ((to_per_cycle_12 / num_cycle) * car_num);
		} else {
			per_cycle_12 <- nil;
		}
		
		if to_per_cycle_13 != 0.0 {
			per_cycle_13 <- finish_cycle / ((to_per_cycle_13 / num_cycle) * car_num);
		} else {
			per_cycle_13 <- nil;
		}
		
		if to_per_cycle_14 != 0.0 {
			per_cycle_14 <- finish_cycle / ((to_per_cycle_14 / num_cycle) * car_num);
		} else {
			per_cycle_14<- nil;
		}
		
		if to_per_cycle_15 != 0.0 {
			per_cycle_15 <- finish_cycle / ((to_per_cycle_15 / num_cycle) * car_num);
		} else {
			per_cycle_15 <- nil;
		}
		
		if to_per_cycle_16 != 0.0 {
			per_cycle_16 <- finish_cycle / ((to_per_cycle_16 / num_cycle) * car_num);
		} else {
			per_cycle_16 <- nil;
		}

		//---------------------------------------------------------------------------
		
		create road from:shape_file_road with:[
			//readでシェイプファイルの属性の値を予め作成した関数に格納
			p_lane_r::int(read("planesu")),
			m_lane_r::int(read("mlanesu")),
			one_way::int(read("oneway")), 
			maxspeed::float(read("maxspeed")),
			num_lanes::int(read("lanes")),
			aco_road::int(read("aco_road"))
		]
		{	
			
			if p_lane_r = nil or p_lane_r = 0{
				num_lanes <- 1;
			}else {
				num_lanes <- p_lane_r;
			}
			
			if maxspeed = nil or maxspeed = 0.0{
				maxspeed <- 30.0;
			}
			
			//one_wayがNoなら(一方通行でないなら)もう一方向向けのロードを作成
			if one_way = 0 {
				create road {
					self.location <- myself.location;
					self.shape <- polyline(reverse(myself.shape.points)); //.pointsでオブジェクト（road）を構成する点たちのリストを取得し、revereseでそれのつなぐ方向（始点と終点）のリストを反転し、polylineで再結合
					self.maxspeed <- myself.maxspeed;
					self.num_lanes <- myself.num_lanes;
					self.p_lane_r <- myself.p_lane_r;
					self.m_lane_r <- myself.m_lane_r;
					self.aco_road <- myself.aco_road;
					self.linked_road <- myself;
					myself.linked_road <- self;
				}
			}
			
			
		}
		
		//交差点を生成
		create intersection from:shape_file_node with:
		[
			signal_type::(string(read("signaltype"))),
			inter_num::(int(read("nodeno")))
		];
		
		// 道路ネットワークを作成（道と交差点を結合）
		road_network <- as_driving_graph(road, intersection);

		ask intersection {
			if length(roads_in)=0 and length(self.roads_out)=0 {
				do die;
			}
			
			stop << []; //この空のリストをstopに代入しないとjavaエラー
		}
		
		create building from:shape_file_building with:
		[
			areano::(int(read("areano")))
		];
		
		create water from:shape_file_water {
			
		}
		
		create rail from:shape_file_rail {
			
		}
		
		create north_west_area from:shape_file_morth_west_area {
			
		}
		
		//normal_carを生成
//		create normal_car number:100 with:[born_timing::"first"];
		
		create Administrator {
			
		}
		
		
		//ACO用の、道路実データをそれぞれの道路に格納
		loop i over:actual_road_volume {
			if loop_counter = 0 or loop_counter mod 2 = 0 {
				ask road(i) {
					dummy_volume <- actual_road_volume[loop_counter + 1];
				}
			}
			loop_counter <- loop_counter + 1;
		}	
		
		
		//ここに置かないとちゃんと更新されてないぞ！！！！！！！！！！！！！！！！！
		per_cycle_list <- ["c1"::per_cycle_1, "c2"::per_cycle_2, "c3"::per_cycle_3, "c4"::per_cycle_4, "c5"::per_cycle_5, "c6"::per_cycle_6, "c7"::per_cycle_7, "c8"::per_cycle_8, "c9"::per_cycle_9, "c10"::per_cycle_10, "c11"::per_cycle_11, "c12"::per_cycle_12, "c13"::per_cycle_13, "c14"::per_cycle_14, "c15"::per_cycle_15, "c16"::per_cycle_16];
		//GA_data用　place_1,place_2,,,によって指定された番号（GAで決定）：：その番号が対応する道路
//		map<int,road> map_place <- [1::road(948), 2::road(1088), 3::road(323), 4::road(400), 5::road(102), 6::road(922), 7::road(31), 8::road(641), 9::road(254), 10::road(54), 11::road(428), 12::road(840), 13::road(835), 14::road(384), 15::road(107), 16::road(317)];
		
		//newgetdummyで０になっちゃってる部分を強制
		map<int,road> map_place <- [1::road(948), 2::road(1088), 3::road(323), 4::road(269), 5::road(102), 6::road(922), 7::road(31), 8::road(641), 9::road(254), 10::road(54), 11::road(428), 12::road(840), 13::road(835), 14::road(223), 15::road(107), 16::road(317)];

			

		
		//ダミー用全インター交通量取得
		ask intersection where(!(each.index in checkpoint_intersection)) {
			add self.index to:another_intersection;
		}
		
		//計測交差点において、４叉路と３叉路の判定、ABCD割り振り、それぞれからの侵入で右左折直進ペアの判定
		loop x over:checkpoint_intersection {
			ask intersection where(each.index = x){			
				loop i over:roads_in {
					abc <- min(intersection(road(i).source_node).id,intersection(road(i).target_node).id)::max(intersection(road(i).source_node).id,intersection(road(i).target_node).id);
					if abc in def.values {
						if road(i) in def.keys {			
										
						} else {
							
						}		
					} else {
						def[road(i)] <- abc;					
					}
				}
				loop j over:roads_out {
					abc <- min(intersection(road(j).source_node).id,intersection(road(j).target_node).id)::max(intersection(road(j).source_node).id,intersection(road(j).target_node).id);
					if abc in def.values {
						if road(j) in def.keys {			
//							write def.keys(where(road(j) in each));
						} else {
							list<road> temp_road_list <- [];
							list temp_2;
							map<list<road>,pair> temp_map;
							
							temp_2 <- def.keys(where (each.values = abc));
							loop i over:temp_2 {
								if road(i[0]).linked_road != nil and road(i[0]).linked_road = road(j) {
									temp_road_list <- road(i[0]);
									add road(j) to:temp_road_list;
									temp_map[temp_road_list] <- def[i];
									def[] >- i;
									def <- def + temp_map;
								}
							}
						}		
					} else {
						def[road(j)] <- abc;				
					}
				}
//				write name + ":def:" + def;
				
				count <- 0;
				loop i over:def.keys {
					if i[0].target_node = intersection(x) {
						temp_min_direction_360 <- int(direction_to(i[0].source_node,i[0].target_node));
					} else {
						temp_min_direction_360 <- int(direction_to(i[0].target_node,i[0].source_node));
					}					
						
					// 角度を -180〜179度の範囲に正規化
					if temp_min_direction_360 > 180 {
						temp_min_direction_180 <- temp_min_direction_360 - 360;
					} else {
						temp_min_direction_180 <- temp_min_direction_360;
					}
					add i :: temp_min_direction_180 to: direction_list_180;
					add i :: temp_min_direction_360 to: direction_list_360;
					count <- count + 1;
				}
				//角度の絶対値で昇順ソート
				direction_list_180 <- direction_list_180 sort_by (abs(each.value));
				direction_list_360 <- direction_list_360 sort_by (abs(each.value));
				
				
				//４叉路の場合 ABCD指定
				if length(def) = 4 {
					four_way <- true;
					//Dを代入（世界座標で一番数字が小さいやつ）
					road_d <- direction_list_180[0].key;
					//Dを削除
					direction_list_360 <- direction_list_360 where (each.key != road_d);					
					road_a <- direction_list_360[0].key;
					road_b <- direction_list_360[1].key;
					road_c <- direction_list_360[2].key;
				}
			
				//３叉路の場合　ABC指定
				else if length(def) = 3 {
					//三叉路は４パターン（東西南北どの道路がないか）で判定
					//パターン１　北（世界座標90度付近）無しの場合
					if (length(direction_list_360 where(60 <= each.value and each.value <= 120)) = 0) {
						three_way_1 <- true;
						road_c <- direction_list_180[0].key;
						direction_list_360 <- direction_list_360 where (each.key != road_c);
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					}
					//パターン２　南（世界座標270度付近）無しの場合
					else if (length(direction_list_360 where(240 <= each.value and each.value <= 300)) = 0) {
						three_way_2 <- true;
						road_c <- direction_list_180[0].key;
						direction_list_360 <- direction_list_360 where (each.key != road_c);
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					}
					//パターン３　西（世界座標0度付近）無しの場合
					else if (length(direction_list_180 where(0 <= abs(each.value) and abs(each.value) <= 30)) = 0) {
						three_way_3 <- true;
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
						road_c <- direction_list_360[2].key;
					}
					//パターン４　東（世界座標180度付近）無しの場合
					else if (length(direction_list_360 where(150 <= each.value and each.value <= 210)) = 0) {
						three_way_4 <- true;
						road_c <- direction_list_180[0].key;
						direction_list_360 <- direction_list_360 where (each.key != road_c);
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					}
				}				
			}
		}
		
		
		loop x over:another_intersection {
			ask intersection where(each.index = x){			
				loop i over:roads_in {
					abc <- min(intersection(road(i).source_node).id,intersection(road(i).target_node).id)::max(intersection(road(i).source_node).id,intersection(road(i).target_node).id);
					if abc in def.values {
						if road(i) in def.keys {			
										
						} else {
							
						}		
					} else {
						def[road(i)] <- abc;					
					}
				}
				loop j over:roads_out {
					abc <- min(intersection(road(j).source_node).id,intersection(road(j).target_node).id)::max(intersection(road(j).source_node).id,intersection(road(j).target_node).id);
					if abc in def.values {
						if road(j) in def.keys {			
//							write def.keys(where(road(j) in each));
						} else {
							list<road> temp_road_list <- [];
							list temp_2;
							map<list<road>,pair> temp_map;
							
							temp_2 <- def.keys(where (each.values = abc));
							loop i over:temp_2 {
								if road(i[0]).linked_road != nil and road(i[0]).linked_road = road(j) {
									temp_road_list <- road(i[0]);
									add road(j) to:temp_road_list;
									temp_map[temp_road_list] <- def[i];
									def[] >- i;
									def <- def + temp_map;
								}
							}
						}		
					} else {
						def[road(j)] <- abc;				
					}
				}
//				write name + ":def:" + def;
				
				count <- 0;
				loop i over:def.keys {
					if i[0].target_node = intersection(x) {
						temp_min_direction_360 <- int(direction_to(i[0].source_node,i[0].target_node));
					} else {
						temp_min_direction_360 <- int(direction_to(i[0].target_node,i[0].source_node));
					}					
						
					// 角度を -180〜179度の範囲に正規化
					if temp_min_direction_360 > 180 {
						temp_min_direction_180 <- temp_min_direction_360 - 360;
					} else {
						temp_min_direction_180 <- temp_min_direction_360;
					}
					add i :: temp_min_direction_180 to: direction_list_180;
					add i :: temp_min_direction_360 to: direction_list_360;
					count <- count + 1;
				}
				//角度の絶対値で昇順ソート
				direction_list_180 <- direction_list_180 sort_by (abs(each.value));
				direction_list_360 <- direction_list_360 sort_by (abs(each.value));
				
				
				//４叉路の場合 ABCD指定
				if length(def) = 4 {
					four_way <- true;
					//Dを代入（世界座標で一番数字が小さいやつ）
					road_d <- direction_list_180[0].key;
					//Dを削除
					direction_list_360 <- direction_list_360 where (each.key != road_d);					
					road_a <- direction_list_360[0].key;
					road_b <- direction_list_360[1].key;
					road_c <- direction_list_360[2].key;
				}
			
				//３叉路の場合　ABC指定
				else if length(def) = 3 {
					//三叉路は４パターン（東西南北どの道路がないか）で判定
					//パターン１　北（世界座標90度付近）無しの場合
					if (length(direction_list_360 where(60 <= each.value and each.value <= 120)) = 0) {
						three_way_1 <- true;
						road_c <- direction_list_180[0].key;
						direction_list_360 <- direction_list_360 where (each.key != road_c);
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					}
					//パターン２　南（世界座標270度付近）無しの場合
					else if (length(direction_list_360 where(240 <= each.value and each.value <= 300)) = 0) {
						three_way_2 <- true;
						road_c <- direction_list_180[0].key;
						direction_list_360 <- direction_list_360 where (each.key != road_c);
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					}
					//パターン３　西（世界座標0度付近）無しの場合
					else if (length(direction_list_180 where(0 <= abs(each.value) and abs(each.value) <= 30)) = 0) {
						three_way_3 <- true;
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
						road_c <- direction_list_360[2].key;
					}
					//パターン４　東（世界座標180度付近）無しの場合
					else if (length(direction_list_360 where(150 <= each.value and each.value <= 210)) = 0) {
						three_way_4 <- true;
						road_c <- direction_list_180[0].key;
						direction_list_360 <- direction_list_360 where (each.key != road_c);
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					}
				}	
				
				else if length(def) = 2 {
					two_way <- true;
					if abs(direction_list_360[0].value - 180) < abs(direction_list_360[1].value - 180) {
						road_a <- direction_list_360[0].key;
						road_b <- direction_list_360[1].key;
					} else {
						road_a <- direction_list_360[1].key;
						road_b <- direction_list_360[0].key;
					}
					
				}	 
				
				else {
					one_way <- true;
					road_a <- direction_list_360[0].key;
				}		
			}
		}
	}
	
	
	
	output {
		display show_sim type:opengl{
			species road refresh:false;
			species normal_car;
			species building refresh:false;
			species water refresh:false;
			species rail refresh:false;
			species pedestrian;
			species pedestrian_path refresh:false;
			species intersection refresh:false;
			
		}
	}
}
