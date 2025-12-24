/**
* Name: PedestrianPath
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model PedestrianPath

/* Insert your model definition here */
import "Parameters.gaml"
import "Main.gaml"

/**
 * Pedestrian-Path Generator Agent: 歩行者パス生成エージェント
 */
species pedestrian_path_make {
	init {
		create pedestrian_path from: shape_file_pedestrian_road {
			//フリースペースは絶対必要！（pedestrianが厳密にネットワークに乗っているわけではない）
			list<geometry> fs <- shape_file_pedestrian_road_freespace overlapping self;
			free_space <- fs first_with (each covers shape); 
		}
		create pedestrian_path from: shape_file_pedestrian_crossing {
			//フリースペースは絶対必要！（pedestrianが厳 密にネットワークに乗っているわけではない）
			list<geometry> fs <- shape_file_pedestrian_crossing_freespace overlapping self;
			free_space <- fs first_with (each covers shape); 
		}
		pedestrian_network <- as_edge_graph(pedestrian_path);
		do die;
	}
}

/**
 * Pedestrian-Path Agent: 歩行者パスエージェント
 */
species pedestrian_path skills: [pedestrian_road] parallel:true {
	aspect default { 
		draw shape  color: #lightblue ;
	}
}