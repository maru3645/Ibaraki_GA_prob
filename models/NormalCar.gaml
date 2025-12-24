/**
* Name: Normalcar
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Normalcar

/* Insert your model definition here */

import "./Main.gaml"
import "./Vehicle.gaml"

global {
	list<road> checkpoint_road <- [road(1091),road(641),road(1066),road(612),road(593),road(614),road(1068),road(944),road(434),road(983),road(487),road(978),road(481),road(683),road(54),road(653),road(12),road(1083),road(632),road(933),road(413),road(689),road(60),road(167),road(351),road(888),road(1006),road(520),road(254),road(60),road(689),road(807),road(227),road(271),road(835),road(356),road(892),road(645),road(0),road(941),road(428)]; //右左折・直進の確率判定をする、交差点に接するroadを格納
	list<int> checkpoint_intersection <- [23,19,32,20,152,21,33]; //indexです
	
	list<int> another_intersection <- [];
	
	list<int> dummy_num_road <- [948,441,1088,637,323,400,716,102,398,922,669,31,277,840]; //ダミーデータを取得するロードのindex
	
	//以下ダミーに合わせる際のo候補のinterのid
	list<int> id_north_west <- [423,424,425,426,427,428]; //上の左
	list<int> id_west <- [477,478,479,480,481];//左
	list<int> id_south_west <- [471,472,473,474,475,476];//下の左
	
	list<int> id_north_east <- [437,438,439,440,441,442];//上の右
	list<int> id_east_north <- [443,444,445,446];//右の上
	list<int> id_east_south <- [448,449,450,451,452];//右の下
	list<int> id_south_east <- [453,454,455,456,457];//下の右
	
	list<int> id_north_city_office <- [429,430]; //市役所北
	list<int> id_south_city_office <- [464,465,466]; //市役所南
}

//Vehicleを継承
species normal_car parent:vehicle{
	intersection o; //始点
	intersection d; //目的地
	intersection o_2; //ACO用のもの
	date d_time; //出発時間
	road before_road; //過去のcurrent_roadを入れ現在と比較
	road temporary_bofore_road;
	intersection before_target;
	intersection temporary_before_target;
	path change_path;
	int path_counter <- 0;
	bool not_on_point <- false;
	string born_timing;
	int o_id;
	int d_id;
	int direction; //台数調整する際の上下左右方向を選択
	int timer <- 0;
	
	int o_check;
	
	//計測を一つの道路に乗ってるときに一回のみ行うためのbool
	bool countable <- false;
	
	int counter;
	
	geometry line;
	road ag;
	
	list<intersection> aco_target_list <- []; //ACOの時の通るルートを保持
	list<road> aco_road_list <- []; //ACOの時の通るルートを保持
	list<pair<intersection,road>> aco_choice_map; //次の経路を選択時に、選択肢となる次のターゲットと、道路
	list<road> temp_next_road;
	intersection current_aco_target;
	road current_aco_road;
	
	list<float> aco_choice_pheromone <- []; //次の選択肢のフォロモン量のリスト
	list<int> aco_raffle_list <- []; //経路決定時に0,1,2,3（それぞれaco_choice_mapに対応）を移動可能な道路内のフェロモン量の割合（％）分だけ格納し、この中からランダムで選ばせて移動先にする
	int difference_volume; //フェロモン生成計算時に使う差
	float increase_pheromone <- 0.0; //増加するフェロモン量
	int next_out_index; //抽選した結果を格納（0,1,2,3）次医の目的地のaco_choice_mapのindex
	int random_walk_prob <- 5; //毎回の経路選択時に、フェロモンに依存せず、ランダムになる確率
	int def_method_walk;
	int random_number;
	list<road> increased_road <- []; //複数回その道路を通ってても、一回だけフェロモンを追加をする
	
	int loop_count <- 0;
	int checker <- 0;
	
	list<path> temp_path_list <- []; //候補のパス10個を入れるリスト
	map<path,float> weight_map <- []; //候補のパスと、その重みを右左折直進の確率を適用して足し合わせたのを入れる
	list<road> path_road_list <- []; //pathをroadのlistに変換したもの
	list<road> verification_road <- []; //道路を２個ずつ入れて、その２個が確率重みづけ対象地点なら、重みを変更するようにする
	int loop_checker <- 0;
	float num_weight; //道路の重さ再計算用
	list<intersection> all_intersection; //現在計算中のパスにおける走行するintersectionを格納
	int temp_index; //計算中の今のinterが計測地点の何番目かを格納
	float new_weight; //新しい重みを格納
	float data_prob; //データにおける確率
	bool four_inter <- false; //四さろかどうか　そうならtrue
	  
	init {
		drive_ov <- true;
		vehicle_length <- 3.4;
		
		//ネットワーク上でodがつながるまでループ
		loop while: true and not_on_point = false{
			timer <- timer + 1;
			if timer = 5 {
//				write name + "timing:" + born_timing;
				do die;
			}
			if born_timing = "1" {		
				o_check <- one_of(o_to_1);
				if o_check = 1 {
					o_id <- one_of(id_north_east);				
				} else if o_check = 2 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 4 {
					o_id <- one_of(id_south_east);	
				} else if o_check = 5 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 6 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 7 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 298;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} 
			
			else if born_timing = "2" {
				o_check <- one_of(o_to_2);
				if o_check = 1 {
					o_id <- one_of(id_north_east);				
				} else if o_check = 2 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 4 {
					o_id <- one_of(id_south_east);	
				} else if o_check = 5 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 6 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 7 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 189;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "3" {
				o_check <- one_of(o_to_3);
				if o_check = 1 {
					o_id <- one_of(id_north_east);				
				} else if o_check = 2 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 4 {
					o_id <- one_of(id_south_east);	
				} else if o_check = 5 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 6 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 7 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 250;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "4" {
				o_check <- one_of(o_to_4);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 483;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "5" {
				o_check <- one_of(o_to_5);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 370;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} 
			
			else if born_timing = "6" {
				o_check <- one_of(o_to_6);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 124;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} 
			
			else if born_timing = "7" {
				o_check <- one_of(o_to_7);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 291;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "8" {
				o_check <- one_of(o_to_8);
				if o_check = 1 {
					o_id <- one_of(id_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 4 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else {
					o_id <- 463;	
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 52;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "9" {
				o_check <- one_of(o_to_9);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 4 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 5 {
					o_id <- one_of(id_north_city_office);	
				} else {
					o_id <- 432;	
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 270;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "10" {
				o_check <- one_of(o_to_10);
				if o_check = 1 {
					o_id <- one_of(id_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 4 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else {
					o_id <- 463;	
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d <- intersection(256);
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "11" {
				o_check <- one_of(o_to_11);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 4 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 5 {
					o_id <- one_of(id_north_city_office);	
				} else {
					o_id <- 432;	
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d <- intersection(463);
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "12" {
				o_check <- one_of(o_to_12);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 119;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "13" {
				o_check <- one_of(o_to_13);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_east_north);	
				} else if o_check = 4 {
					o_id <- one_of(id_east_south);	
				} else if o_check = 5 {
					o_id <- one_of(id_north_city_office);	
				} else {
					o_id <- 432;	
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 149;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "14" {
				o_check <- one_of(o_to_14);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 208;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "15" {
				o_check <- one_of(o_to_15);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 214;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "16" {
				o_check <- one_of(o_to_16);
				if o_check = 1 {
					o_id <- one_of(id_north_west);				
				} else if o_check = 2 {
					o_id <- one_of(id_west);	
				} else if o_check = 3 {
					o_id <- one_of(id_south_west);	
				} else if o_check = 4 {
					o_id <- one_of(id_north_city_office);	
				} else if o_check = 5 {
					o_id <- one_of(id_south_city_office);	
				} else if o_check = 6 {
					o_id <- 432;	
				} else {
					o_id <- 463;
				}
				ask intersection where(each.id = o_id) {
					myself.o <- self;
				}
				location <- o.location;
				d_id <- 111;
				ask intersection where(each.id = d_id) {
					myself.d <- self;
				}
//				current_path <- compute_path(graph: road_network, target:d);
				do path_by_prob;
			} else if born_timing = "random" {
				o <- one_of(intersection);
				d <- one_of(intersection);
				if o != d {
					location <- o.location;
					current_path <- compute_path(graph: road_network, target: intersection(d));
				}		
			} else if born_timing = "dummy" {
				int z <- rnd(0,1);
				if z = 0 {
					o_id <- 432;
					ask intersection where(each.id = o_id) {
						myself.o <- self;
					}
					location <- o.location;
					z <- rnd(0,1);
					if z = 0 {
						d <- intersection(463);
					} else {
						d <- one_of(intersection);
					}
//					current_path <- compute_path(graph: road_network, target:d);
					do path_by_prob;
				} else {
					o_id <- 463;
					ask intersection where(each.id = o_id) {
						myself.o <- self;
					}
					location <- o.location;
					z <- rnd(0,1);
					if z = 0 {
						d <- intersection(432);
					} else {
						d <- one_of(intersection);
					}
//					current_path <- compute_path(graph: road_network, target:d);
					do path_by_prob;
				}
			} 
			
			//重さ再計算用
			else if  born_timing = "test" {
				o <- (intersection(281));
				d <- (intersection(280));
//				o <- one_of(intersection);
//				d <- one_of(intersection);
				location <- o.location;
				do path_by_prob;
			}
			
			else {
				o <- one_of(intersection);
				d <- one_of(intersection);
				if o != d {
					location <- o.location;
					current_path <- compute_path(graph: road_network, target: intersection(d));
				}				
			}
			
			write "f";
			
			if current_path != nil{
				//pathの最初のroadがoのroad_ontに入ってたらOK!!この処理マジ重要！！！！！！！！！！！！！！！！！
				line <- (current_path.segments[0]);
				ag <- road(current_path agent_from_geometry line);
				if  ag in intersection(o).roads_out {
					write "g";
					break;
				}			
			}
		}
	}
	
	reflex change_before_read when:current_road != nil {
		//before_roadを格納
		if (current_road) != (temporary_bofore_road) {
			before_road <- (temporary_bofore_road);
			temporary_bofore_road <- road(current_road); 
			countable <- true;
		} else {
			temporary_bofore_road <- road(current_road);
			countable <- false;
		}
	}
	
	reflex change_before_target when: current_target != nil {
		//before_targetを格納
		if (current_target) != (temporary_before_target) {
			before_target <- (temporary_before_target);
			temporary_before_target <- intersection(current_target); 
		} else {
			temporary_before_target <- intersection(current_target);
		}
	}
	
	
	//初期状態作成ここまで-----------------------------------------------------------------------------------
	
	
	reflex count_road_volume when:current_road != nil and countable {
		ask road(current_road) {
			volume <- volume + 1;
		}
	}
	
	//新システム断面交通量取得 完成
	reflex count_volume when:current_road != nil and before_target != nil and current_target != nil and countable{
		if before_road != current_road {
			if intersection(current_target).id in checkpoint_intersection {
				do add_volume(intersection(current_target));
			}			
			if intersection(before_target).id in checkpoint_intersection {
				do add_volume(intersection(before_target));
			}
		}		
	}
	
	reflex dummy_count_volume when:current_road != nil and before_target != nil and current_target != nil and countable{
		if before_road != current_road {
			if intersection(current_target).id in another_intersection {
				do add_volume(intersection(current_target));
			}			
			if intersection(before_target).id in another_intersection {
				do add_volume(intersection(before_target));
			}
		}		
	}
	
	//新システム右左折直進の方向ごとの数計測
	reflex new_count_direction when:before_target != nil and current_road != nil and before_road != nil and countable {
		if before_target.id in checkpoint_intersection {
			ask before_target {
				//四叉路の場合
				if four_way {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_d {
							from_a_volume[0] <- from_a_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_a_volume[1] <- from_a_volume[1] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_d {
							from_b_volume[1] <- from_b_volume[1] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[1] <- from_c_volume[1] + 1;
						} else if road(myself.current_road) in road_d {
							from_c_volume[2] <- from_c_volume[2] + 1;
						}
					}
					//Dから侵入
					else if myself.before_road in road_d {
						if road(myself.current_road) in road_c {
							from_d_volume[0] <- from_d_volume[0] + 1;
						} else if road(myself.current_road) in road_b {
							from_d_volume[1] <- from_d_volume[1] + 1;
						} else if road(myself.current_road) in road_a {
							from_d_volume[2] <- from_d_volume[2] + 1;
						}
					}
				}
				//三叉路の場合
				else if three_way_1 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[1] <- from_a_volume[1] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[1] <- from_c_volume[1] + 1;
						}
					}
				} else if three_way_2 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[0] <- from_a_volume[0] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[1] <- from_b_volume[1] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[1] <- from_c_volume[1] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[2] <- from_c_volume[2] + 1;
						}
					}
				} else if three_way_3 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[1] <- from_a_volume[1] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[1] <- from_c_volume[1] + 1;
						}
					}
				} else if three_way_4 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[0] <- from_a_volume[0] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[1] <- from_a_volume[1] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[1] <- from_b_volume[1] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[2] <- from_c_volume[2] + 1;
						}
					}
				}
				
				else if two_way {
					if road(myself.current_road) in road_b {
						from_a_volume[1] <- from_a_volume[1] + 1;
					} else if road(myself.current_road) in road_a {
						from_b_volume[1] <- from_b_volume[1] + 1;
					}
				} 
			}
		}
	}
	
	
	//ダミー用にほかの全交差点計測
	reflex dummy_count_direction when:before_target != nil and current_road != nil and before_road != nil and countable {
		if before_target.id in another_intersection {
			ask before_target {
				//四叉路の場合
				if four_way {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_d {
							from_a_volume[0] <- from_a_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_a_volume[1] <- from_a_volume[1] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_d {
							from_b_volume[1] <- from_b_volume[1] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[1] <- from_c_volume[1] + 1;
						} else if road(myself.current_road) in road_d {
							from_c_volume[2] <- from_c_volume[2] + 1;
						}
					}
					//Dから侵入
					else if myself.before_road in road_d {
						if road(myself.current_road) in road_c {
							from_d_volume[0] <- from_d_volume[0] + 1;
						} else if road(myself.current_road) in road_b {
							from_d_volume[1] <- from_d_volume[1] + 1;
						} else if road(myself.current_road) in road_a {
							from_d_volume[2] <- from_d_volume[2] + 1;
						}
					}
				}
				//三叉路の場合
				else if three_way_1 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[1] <- from_a_volume[1] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[1] <- from_c_volume[1] + 1;
						}
					}
				} else if three_way_2 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[0] <- from_a_volume[0] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[1] <- from_b_volume[1] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[1] <- from_c_volume[1] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[2] <- from_c_volume[2] + 1;
						}
					}
				} else if three_way_3 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[1] <- from_a_volume[1] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[2] <- from_a_volume[2] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[0] <- from_b_volume[0] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[1] <- from_c_volume[1] + 1;
						}
					}
				} else if three_way_4 {
					//Aから侵入
					if myself.before_road in road_a {
						//右折・直進・左折の順番
						if road(myself.current_road) in road_c {
							from_a_volume[0] <- from_a_volume[0] + 1;
						} else if road(myself.current_road) in road_b {
							from_a_volume[1] <- from_a_volume[1] + 1;
						}
					}
					//Bから侵入
					else if myself.before_road in road_b {
						if road(myself.current_road) in road_a {
							from_b_volume[1] <- from_b_volume[1] + 1;
						} else if road(myself.current_road) in road_c {
							from_b_volume[2] <- from_b_volume[2] + 1;
						}
					}
					//Cから侵入
					else if myself.before_road in road_c {
						if road(myself.current_road) in road_b {
							from_c_volume[0] <- from_c_volume[0] + 1;
						} else if road(myself.current_road) in road_a {
							from_c_volume[2] <- from_c_volume[2] + 1;
						}
					}
				}
				
				else if two_way {
					if road(myself.current_road) in road_b {
						from_a_volume[1] <- from_a_volume[1] + 1;
					} else if road(myself.current_road) in road_a {
						from_b_volume[1] <- from_b_volume[1] + 1;
					}
				} 
			}
		}
	}
	
	
	// ドライブする final_targetはd(目的地)で、dに到達すると自動的にfinal_targetがnilになる
	reflex move_action when:drive_ov=true and final_target !=nil {
		do drive();
	}
	
	//終了処理
	reflex time_to_finish when:drive_ov=true and current_target = nil {
		drive_ov <- false;
		do die;
	}
	
	action road_num {
		if before_road != current_road {
			ask road(current_road) {
				num_cars <- num_cars + 1;
			}				
		}
	}
	
	action add_volume (intersection x) {
		ask intersection(x) {
			if road(myself.current_road) in road_a {
				a_volume <- a_volume + 1;
			} else if road(myself.current_road) in road_b {
				b_volume <- b_volume + 1;
			} else if road(myself.current_road) in road_c {
				c_volume <- c_volume + 1;
			} else if road(myself.current_road) in road_d {
				d_volume <- d_volume + 1;
			}
		}
	}
	
	//データ確率に従ったパス計算方法
	action path_by_prob {
		if o != d {
//			location <- o.location;
			//コストが少ない順に１０個パスを出力
			temp_path_list <- paths_between(road_network, o:: d, 20);
			//それぞれのパスの重みを計算し、mapに代入
			if temp_path_list != nil {
				loop i over:temp_path_list {
					if i != nil {
						path_road_list <- list<road>(i.edges);
						all_intersection <- list<intersection>(i.vertices);
//								write all_intersection;
						loop_checker <- 0;
						num_weight <- 0.0;
						verification_road <- [];
						if path_road_list != nil {
							loop j over:path_road_list {
								//リストに２個ずつ格納し、パスのコストを計算(リストに二つずつ入れて、)コストの計算を行うのはリストの最後尾終わったら０番目を削除し次へ
								add j to:verification_road;
								if loop_checker = 0 {
//											write name + " : " + verification_road;
									num_weight <- num_weight + weight_of(road_network,verification_road[0]);
								} else if loop_checker = 1{
									//対象７地点に入っているなら、右左折直進の確率コストを付与した計算を行う
									if all_intersection[loop_checker].index in checkpoint_intersection {
//										prob_load_list <- [2.5, 15.0, 5.0, 2.5, 13.2, 18.3, 10.5]; //お試し用実際はGAから贈られる
										//その交差点が計測地点の何番かを特定
										temp_index <- checkpoint_intersection index_of all_intersection[loop_checker].index;
										//その交差点が四叉路か三叉路か、そして、どこからどこに行くのかを特定し、実データの確率を特定し、新重みを計算
										ask intersection where(each.index = checkpoint_intersection[temp_index]) {
											//まずはdata_probに実際の確率を格納
											if four_way {
												myself.four_inter <- true;
												//point1,3,5,6,7
												//Aから侵入
												if myself.verification_road[0] in road_a {
													//右折・直進・左折の順番
													if myself.verification_road[1] in road_d {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12]; //point3ならindexが24
														}									
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 1];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 1]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 2];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 2]; //point3ならindexが24
														}	
													}
												}
												//Bから侵入
												else if myself.verification_road[0] in road_b {
													if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 3];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 3]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_d {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 4];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 4]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 5];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 5]; //point3ならindexが24
														}	
													}
												}
												//Cから侵入
												else if myself.verification_road[0] in road_c {
													if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 6];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 6]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 7];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 7]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_d {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 8];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 8]; //point3ならindexが24
														}	
													}
												}
												//Dから侵入
												else if myself.verification_road[0] in road_d {
													if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 9];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 9]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 10];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 10]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 11];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 11]; //point3ならindexが24
														}	
													}
												}
												
											} else if three_way_1 {
												myself.four_inter <- false;
												//point2 北がないやつ
												//Aから侵入
												if myself.verification_road[0] in road_a {
													//右折・直進・左折の順番
													if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 1];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 1]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 2];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 2]; //point3ならindexが24
														}
													}
												}
												//Bから侵入
												else if myself.verification_road[0] in road_b {
													if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 3];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 3]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 5];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 5]; //point3ならindexが24
														}
													}
												}
												//Cから侵入
												else if myself.verification_road[0] in road_c {
													if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 6];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 6]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 7];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 7]; //point3ならindexが24
														}
													}
												}
											} else if three_way_2 {
												myself.four_inter <- false;
											} else if three_way_3 {
												myself.four_inter <- false;
											} else if three_way_4 {
												myself.four_inter <- false;
												//point4 東がないやつ
												//Aから侵入
												if myself.verification_road[0] in road_a {
													//右折・直進・左折の順番
													if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 1];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 1]; //point3ならindexが24
														}
													}
												}
												//Bから侵入
												else if myself.verification_road[0] in road_b {
													if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 4];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 4]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 5];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 5]; //point3ならindexが24
														}
													}
												}
												//Cから侵入
												else if myself.verification_road[0] in road_c {
													if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 6];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 6]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 8];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 8]; //point3ならindexが24
														}
													}
												}
											}
										}
										
										//新しい重みを計算
										if four_inter {
											new_weight <- (weight_of(road_network,verification_road[1])) * max(0.1, (1.0 + prob_load_list[temp_index] * (0.25 - data_prob)));
										} else {
											new_weight <- (weight_of(road_network,verification_road[1])) * max(0.1, (1.0 + prob_load_list[temp_index] * (0.33 - data_prob)));
										}
										
										num_weight <- num_weight + new_weight;
//												write checkpoint_intersection index_of all_intersection[loop_checker].index;
									} else {
										num_weight <- num_weight + weight_of(road_network,verification_road[1]);
									}
//											write name + " : " + verification_road;
								} else {
									//最初にリストの先頭を削除
									verification_road <- verification_road - verification_road[0];
									
									//対象７地点に入っているなら、右左折直進の確率コストを付与した計算を行う
									if all_intersection[loop_checker].index in checkpoint_intersection {
//										prob_load_list <- [2.5, 15.0, 5.0, 2.5, 2.3, 1.2, 10.5]; //お試し用実際はGAから贈られる
										//その交差点が計測地点の何番かを特定
										temp_index <- checkpoint_intersection index_of all_intersection[loop_checker].index;
										//その交差点が四叉路か三叉路か、そして、どこからどこに行くのかを特定し、実データの確率を特定し、新重みを計算
										ask intersection where(each.index = checkpoint_intersection[temp_index]) {
											//まずはdata_probに実際の確率を格納
											if four_way {
												myself.four_inter <- true;
												//point1,3,5,6,7
												//Aから侵入
												if myself.verification_road[0] in road_a {
													//右折・直進・左折の順番
													if myself.verification_road[1] in road_d {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12]; //point3ならindexが24
														}									
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 1];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 1]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 2];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 2]; //point3ならindexが24
														}	
													}
												}
												//Bから侵入
												else if myself.verification_road[0] in road_b {
													if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 3];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 3]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_d {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 4];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 4]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 5];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 5]; //point3ならindexが24
														}	
													}
												}
												//Cから侵入
												else if myself.verification_road[0] in road_c {
													if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 6];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 6]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 7];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 7]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_d {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 8];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 8]; //point3ならindexが24
														}	
													}
												}
												//Dから侵入
												else if myself.verification_road[0] in road_d {
													if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 9];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 9]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 10];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 10]; //point3ならindexが24
														}	
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 11];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 11]; //point3ならindexが24
														}	
													}
												}
												
											} else if three_way_1 {
												//point2 北がないやつ
												//Aから侵入
												if myself.verification_road[0] in road_a {
													//右折・直進・左折の順番
													if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 1];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 1]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 2];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 2]; //point3ならindexが24
														}
													}
												}
												//Bから侵入
												else if myself.verification_road[0] in road_b {
													if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 3];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 3]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 5];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 5]; //point3ならindexが24
														}
													}
												}
												//Cから侵入
												else if myself.verification_road[0] in road_c {
													if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 6];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 6]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 7];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 7]; //point3ならindexが24
														}
													}
												}
											} else if three_way_2 {
												myself.four_inter <- false;
											} else if three_way_3 {
												myself.four_inter <- false;
											} else if three_way_4 {
												myself.four_inter <- false;
												//point4 東がないやつ
												//Aから侵入
												if myself.verification_road[0] in road_a {
													//右折・直進・左折の順番
													if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 1];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 1]; //point3ならindexが24
														}
													}
												}
												//Bから侵入
												else if myself.verification_road[0] in road_b {
													if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 4];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 4]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_c {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 5];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 5]; //point3ならindexが24
														}
													}
												}
												//Cから侵入
												else if myself.verification_road[0] in road_c {
													if myself.verification_road[1] in road_b {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 6];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 6]; //point3ならindexが24
														}
													} else if myself.verification_road[1] in road_a {
														if myself.temp_index = 0 {
															myself.data_prob <- aco_dummy_prob[myself.temp_index + 8];
														} else {
															myself.data_prob <- aco_dummy_prob[myself.temp_index * 12 + 8]; //point3ならindexが24
														}
													}
												}
											}
										}
										
										//新しい重みを計算
										if four_inter {
											new_weight <- (weight_of(road_network,verification_road[1])) * max(0.1, (1.0 + prob_load_list[temp_index] * (0.25 - data_prob)));
										} else {
											new_weight <- (weight_of(road_network,verification_road[1])) * max(0.1, (1.0 + prob_load_list[temp_index] * (0.33 - data_prob)));
										}
								
										num_weight <- num_weight + new_weight;
									} else {
										num_weight <- num_weight + weight_of(road_network,verification_road[1]);
									}
								}
								loop_checker <- loop_checker + 1;
							}
							//mapにpathと重み追加
							weight_map[i] <- num_weight;
						}
						
					}	
				}
			}
			if (!empty(weight_map)) {
			    current_path <- (weight_map.keys sort_by (weight_map[each]))[0];
			}		
		}
	}
	
	aspect default {
		draw car_icon size:{3 * 1.7#m, 3 * vehicle_length#m} at: loc rotate: heading +90; // 読み込んだ画像の大きさと場所、向きを変更
	}
}