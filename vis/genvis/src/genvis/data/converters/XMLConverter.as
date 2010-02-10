package genvis.data.converters
{
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	
	import genvis.data.Marriage;
	import genvis.data.Person;
	

	public class XMLConverter 
	{
		public static function xml2Date(xml:XMLList):Date{
			var regExp:RegExp = new RegExp("\\d+", "g");
			var date:Array = xml.toString().match(regExp);
			if (date.length == 0){
				return null;
			}else if (date.length == 1){
				return new Date(date[0], 0, 1);
			}else if (date.length == 2){
				return new Date(date[0], parseInt(date[1])-1);
			}else if (date.length == 3){
				return new Date(date[0], parseInt(date[1])-1, date[2]);
			}
			return new Date(date[0], parseInt(date[1])-1, date[2], date[3], date[4]);		
		}
		/**
		 * Transform genealogy data from xml format into flare's dataset
		 **/
		public static function transform(xml:XML):Array{
			//Transform xml to Flare's Data
			var personsXML:XMLList		= xml.persons.children();
			var rels:XMLList 		= xml.relationships.children();

			//construct nodes from xml
			var map:Object = new Object();
			var personTable:Array = new Array();
			var person:Person;
			for each(var personXML:XML in personsXML){
				person = new Person();				
				person.id				= personXML.id.toString();
				person.name				= personXML.name.toString();
				person.gender			= personXML.gender.toString()!=""? personXML.gender.toString() : null;					
				person.date_of_birth 	= xml2Date(personXML.date_of_birth);
				person.date_of_death	= xml2Date(personXML.date_of_death);		
				map[person.id]   = person; 
				personTable.push(person);		
			}
						
			//construct relation mapping
			for each(var rel:XML in rels){				
				if (rel.relationship_type_id.toString() == 0){
					//parent-child relationship (0) - Hierarchical part
					//0==parent, 1==child, 2==spouse 
					var pid:String = rel.person1_role_type_id.toString()==0? rel.person1_id.toString():rel.person2_id.toString();
					var cid:String = rel.person1_role_type_id.toString()==0? rel.person2_id.toString():rel.person1_id.toString();				
					var parent:Person 	= map[pid];
					var child:Person	= map[cid];
					parent.addChild(child);
					child.addParent(parent);
													
				}else {
					//spouse relationship (1) -  Relational Data
					var spouse1:Person = map[rel.person1_id.toString()];
					var spouse2:Person = map[rel.person2_id.toString()];
					var startDate:Date = xml2Date(rel.date_started);
					var endDate:Date   = xml2Date(rel.date_ended);	
					var marriage:Marriage = new Marriage(spouse1, spouse2, startDate, endDate);
					spouse1.addMarriage(marriage);
					spouse2.addMarriage(marriage);			
				}
			}
			//var nodeSchema:DataSchema = DataUtil.inferSchema(nodes);									
			//return (new DataSet(new DataTable(nodes, nodeSchema)));
			return personTable;
		}		
	}
}