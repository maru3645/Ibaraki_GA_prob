/**
* Name: Pedestrian
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Pedestrian

/* Insert your model definition here */
import "Main.gaml"


species pedestrian_make {
	init {
		create pedestrian number:100{
			pedestrian_model <- "advanced";
			shoulder_length <- 0.5;
//			avoid_other <- true;
//			A_pedestrians_SFM <- 10;
//			B_pedestrians_SFM <- 10;
//			minimal_distance <- 1.0;
//			gama_SFM <- 0.8;
		}
		do die;
	}
}

species pedestrian skills:[pedestrian]{
	point o; //始点
	point d; //目的地
	int enter_checker <- 0;
	
	init{
		shape <- triangle(1);
		
		loop while: true {
			//始点を設定
			o <- any_location_in(one_of(pedestrian_network)); //ランダムな交差点の位置、one_ofはリストの中身からランダムに一つ選択
			location <- o;
			
			//目的地を設定
			d <- any_location_in(one_of(pedestrian_network)); 
			
			//始点から目的地への道順(path)を計算 歩行者パスの場合oとdが同じ場所だとエラーが出る 重要！！！！
			if d != o{
				current_path <- compute_virtual_path(pedestrian_graph: pedestrian_network, target: d); //pathという一つの型。形を持つため.shapeなどで指定できる
			}
			
//			//odが接続されれば抜ける
			if current_path != nil and length(current_path) != 0{
				break;
			}
//			//odが接続されれば抜ける
//			if current_path = nil and length(current_path) != 0{
//				break;
//			}
		}
		
	}

	reflex move when:d != nil{		
		do walk;
	}
	
//	reflex move when:d != nil{		
//		do walk_to target:d bounds:geometry(shape_file_pedestrian_road_freespace);
//	}

	//目的地（pathの最後）につくとcurrent_edgeがnilになる
	reflex die when:current_edge = nil{
		do die;
	}
	
	aspect default {
		draw shape at:location rotate: heading+90 color:#green ;
	}
}