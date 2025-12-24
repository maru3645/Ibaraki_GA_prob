/**
* Name: Parameters
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Parameters

/* Insert your model definition here */

import "./Main.gaml"

global {
	float step <- 1#s; //1サイクル１秒
	
	//スタート時間
	date starting_date <- date("2024 11 22 07 00 00", "yyyy MM dd HH mm ss");	
	file shape_file_road <- file("../includes/shp/road_aco_fix.shp");
	file shape_file_node <- file("../includes/shp/NODE_CUT.shp");
	file shape_file_building <- file("../includes/shp/P_TOWN_BUILDING_CUT.shp");
	file shape_file_water <- file("../includes/shp/P_AREA_WATER_CUT.shp");
	file shape_file_rail <- file("../includes/shp/RAIL_ROAD_CUT.shp");
	file shape_file_pedestrian_road <- file("../includes/shp/sidewalk2.shp");
	file shape_file_pedestrian_crossing <- file("../includes/shp/pedestrian_crossing2.shp");
	file shape_file_pedestrian_road_freespace <- file("../includes/shp/sidewalk2_freespace.shp");
	file shape_file_pedestrian_crossing_freespace <- file("../includes/shp/pedestrian_crossing_freespace2.shp");
	file shape_file_morth_west_area <- file("../includes/shp/north_west_area.shp");
//	file file_actual_road_volume <- csv_file("../includes/new0.9738391130520201/ACO_dummy_road_volume_data.csv");
	matrix<int> actual_road_volume <- matrix<int>(csv_file("../includes/iterate10_seed0.021120334392525142/new_dummy_road_volume_data.csv"));

	
	//シミュレーション環境の形を設定
	geometry shape <- envelope(shape_file_node); //道路データを囲うボックスの形でシミュレーションデータを作成
	
	graph road_network; //道路ネットワークを格納
	
	graph road_network2;
	
	graph pedestrian_network;	// Pedestrian Network: 歩行ネットワーク
	
	file car_icon <- file("..//includes/icons/car_r.png");
}
