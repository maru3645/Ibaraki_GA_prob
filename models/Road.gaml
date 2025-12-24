/**
* Name: Road
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Road

/* Insert your model definition here */

import "./Main.gaml"

species road skills:[road_skill]{
	int one_way; //一方通行か否か
	float maxspeed;
	int num_lanes;
	int p_lane_r;
	int m_lane_r;
	int id; //識別のためのID
	int aco_road;
	
	int num_cars <- 0; //通った車の合計
	
	list<agent> before_all_agents;
	
	float pheromone <- 0.0; //ACO経路選択に使用するフェロモン
	float decrease <- 0.05; //フェロモンの減少量（今回は5パーセント）
	
	int volume <- 0; //ダミー道路の交通量計測用
	
	int dummy_volume <- 0; //フェロモン付与に使用する、実データ（ダミー）
	
	init {
		if self.index = 1091 or 641 or 614 or 1068 or 593 or 1066 or 612 or 944 or 434 or 983 or 487 or 978 or 481 or 683 or 54 or 653 or 12 or 1083 or 632 or 487 or 983 or 481 or 978 or 689 or 60 or 933 or 413 or 167 or 1006 or 520 or 254 or 351 or 888 or 60 or 689 or 8077 or 227 or 271 or 835 or 645 or 0 or 941 or 428 or 356 or 892 {
			add self to:checkpoint_road;
		}
		
		//ダミー計測実データを格納
//		if index mod 2 = 0 {
//			
//		} else {
//			
//		}
		
	}	

	//毎サイクル減少量にのっとってフェロモンを減少
	reflex decrease_pheromone when:pheromone != 0.0 {
		pheromone <- pheromone * (1 - decrease);
	}

	aspect default {
//		draw shape color:#black end_arrow:3; //道路ファイルから勝手に作成してくれる
		if index in [400,428,384] {
			draw shape color:#red end_arrow:3;
		} else {
			draw shape color:#black end_arrow:3;
		}
//		draw string(weight_of(road_network,self)) at:location;
//		draw shape color:#black;
	}
}