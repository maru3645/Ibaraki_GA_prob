/**
* Name: Intersection
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Intersection

/* Insert your model definition here */

import "./Main.gaml"

global {
	//intersectionから出てるroadを数えるための変数
	list<agent> in_out;
	list<agent> out_in;
	string in_string <- "intersection33";
	string out_string <- "intersection82";
	list<agent> result_road;
	bool only_one <- false;
	bool check_num <- false;
}

species intersection skills:[intersection_skill]{
	
	bool is_traffic_signal <- false; //信号フラグ
	string signal_type; //信号機種別
	list<road> v_roads_in; //仮想のroad_in
	int inter_num; //地図データのノード番号連携用
	bool not_node;
	
	list<point> signal_locations;
	
	int signal_counter; //信号現示切り替えのためのカウンター
//	int signal_cycle <- 600; //青から赤の順に切り替わるその一巡する時間(ステップ数が１サイクルなので６０)
	int signal_cycle <- 60; //青から赤の順に切り替わるその一巡する時間(ステップ数が１サイクルなので６０)
	float signal_split <- 0.5; //signal_sycleの時間のうち、１方向に割り当てられる信号時間の配分
	int phase_time <- int(signal_cycle * signal_split); //信号機の時間間隔
	bool is_blue <- true; //1方向が青であるか判定
	list<road> current_shows1;
	list<road> current_shows2;
	int id; //識別のためのID
	
	
	//計測する交差点の交通量を格納
	int a_volume <- 0;
	int b_volume <- 0;
	int c_volume <- 0;
	int d_volume <- 0;
	
	//各計測地点のa,b,c,dから侵入した際の右左折直線の数のリスト（リスト左から順番に右折、直進、左折）

	list<int> from_a_volume <- [0,0,0];	
	list<int> from_b_volume <- [0,0,0];
	list<int> from_c_volume <- [0,0,0];
	list<int> from_d_volume <- [0,0,0];	
	
	list<float> my_probability_result; //最終的にそれぞれの交差点の確率を代入
	
	list<float> num_a <- [0,0,0];
	list<float> num_b <- [0,0,0];
	list<float> num_c <- [0,0,0];
	list<float> num_d <- [0,0,0];
	
	list difference_from_data; //
	
	//対処の交差点のみ挿入（実データ）確率
	list actual_probability <- [];
	
	float angle;//角度を入れる
	
	//自身がどのタイプの交差点か判定
	bool three_way_1 <- false; //北無し
	bool three_way_2 <- false; //南無し
	bool three_way_3 <- false; //西無し
	bool three_way_4 <- false; //東無し
	bool four_way <- false; //４叉路
	
	bool two_way <- false;
	bool one_way <- false;
	
	//交差点に接続する道路の数、道路ABCD判定に使用
	pair abc;
	map<list<road>,pair> def;
	list<road> road_a;
	list<road> road_b;
	list<road> road_c;
	list<road> road_d;
	
	
	int temp_min_direction_180;
	int temp_min_direction_360;
	list<pair<list<road>,int>> direction_list_180 <- nil;
	list<pair<list<road>,int>> direction_list_360 <- nil;
	
	int count;
	
	init {
		//信号機であるかどうか判別
		if (signal_type != nil and signal_type != "1") and self.index in checkpoint_intersection{
//			is_traffic_signal <- true;
		}
		
		//各交差点の実データ
		if index = 23 {
			actual_probability <- [31,55,14,2,92,6,0,0,0,4,92,4];
		} else if index = 19 {
			actual_probability <- [0,94,6,44,0,56,7,93,0,0,0,0];
		} else if index = 32 {
			actual_probability <- [8,83,9,11,79,10,9,82,9,25,60,15];
		} else if index = 20 {
			actual_probability <- [34,66,0,0,71,29,40,0,60,0,0,0];
		} else if index = 152 {
			actual_probability <- [33,46,21,0,90,10,0,0,0,9,91,0];
		} else if index = 21 {
			actual_probability <- [32,7,67,20,79,1,39,31,30,1,84,15];
		} else if index = 33 {
			actual_probability <- [10,70,20,30,67,3,5,80,15,14,67,19];
		}
		
		//ダミー用データ
		if index = 23 {
			actual_probability <- [31,55,14,2,92,6,0,0,0,4,92,4];
		} else if index = 19 {
			actual_probability <- [0,94,6,44,0,56,7,93,0,0,0,0];
		} else if index = 32 {
			actual_probability <- [8,83,9,11,79,10,9,82,9,25,60,15];
		} else if index = 20 {
			actual_probability <- [34,66,0,0,71,29,40,0,60,0,0,0];
		} else if index = 152 {
			actual_probability <- [33,46,21,0,90,10,0,0,0,9,91,0];
		} else if index = 21 {
			actual_probability <- [32,7,67,20,79,1,39,31,30,1,84,15];
		} else if index = 33 {
			actual_probability <- [10,70,20,30,67,3,5,80,15,14,67,19];
		}
		
		if index in checkpoint_intersection {
			
		}
		
		if self.location = nil {
//			write name;
		}
		
	}
	
	reflex when:cycle=0{
		
//		if self.id = 33{
//			signal_split <- 0.7;
//			is_traffic_signal <- false;
//		}
//		
//		if self.id = 32{
////			signal_split <- 0.5;
//			is_traffic_signal <- false;
//		}
//	
//		if self.id = 82{
//			is_traffic_signal <- false;
//		}
//		
//		if self.id =179{
//			is_traffic_signal <- false;
//		}
//		if self.id = 189{
//			is_traffic_signal <- false;
//		}
//		if self.id = 233{
//			is_traffic_signal <- false;
//		}
	}
	
//----------------------------------------------------------------
	
	//信号の切り替え
	reflex control_signal when: signal_counter >= phase_time and is_traffic_signal = true{
//		write road(roads_in[0]);
		signal_counter <- 0;
		if (length(roads_in) >= 4) {//三叉路の場合
//			write road(roads_in[0]);
			if (is_blue) {
				
				stop[0] <- [];
				current_shows1 <- [road(roads_in[0]), road(roads_in[2])];
				stop[0] <- current_shows1;
				phase_time <- int(signal_cycle * signal_split);
			} else {
				current_shows2 <- [road(roads_in[1]), road(roads_in[3])];
				stop[0] <- [];
				stop[0] <- current_shows2;
				phase_time <- int(signal_cycle * (1-signal_split));
			}
		} else if (length(roads_in) = 3) {//三叉路の場合
			if index = 19 {
				if (is_blue) {
					stop[0] <- [];
					current_shows1 <- [road(roads_in[1])];
					stop[0] <- current_shows1;
					phase_time <- int(signal_cycle * signal_split);
				} else {
					stop[0] <- [];
					current_shows2 <- [road(roads_in[0]), road(roads_in[2])];
					stop[0] <- current_shows2;
					phase_time <- int(signal_cycle * (1-signal_split));
				}
			} else if index = 23 {
				if (is_blue) {
					stop[0] <- [];
					current_shows1 <- [road(roads_in[2])];
					stop[0] <- current_shows1;
					phase_time <- int(signal_cycle * signal_split);
				} else {
					stop[0] <- [];
					current_shows2 <- [road(roads_in[0]), road(roads_in[1])];
					stop[0] <- current_shows2;
					phase_time <- int(signal_cycle * (1-signal_split));
				}
			} else {
				if (is_blue) {
					stop[0] <- [];
					current_shows1 <- [road(roads_in[0])];
					stop[0] <- current_shows1;
					phase_time <- int(signal_cycle * signal_split);
				} else {
					stop[0] <- [];
					current_shows2 <- [road(roads_in[1]), road(roads_in[2])];
					stop[0] <- current_shows2;
					phase_time <- int(signal_cycle * (1-signal_split));
				}
			}			
		}
		is_blue <- !is_blue;
	}
	
	// counterをインクリメント
	reflex increment_count when: is_traffic_signal and length(roads_in) > 2{
		signal_counter <- signal_counter + 1;
	}
	
	aspect default {
//		if self.index in checkpoint_intersection{
//			draw string(self.index) at:location color:#black;
//		}
//		draw string(self.id) at:location color:#blue size:self.shape.height;
		draw circle(1) at:location color:#red border:true; // aspectは名前を指定しているもの
//		draw string(index) at:location color:#black size:self.shape.height/2;
	}
}