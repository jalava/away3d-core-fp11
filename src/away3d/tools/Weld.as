﻿package away3d.tools{	import away3d.arcane;	import away3d.containers.ObjectContainer3D;	import away3d.core.base.Geometry;	import away3d.core.base.SubGeometry;	import away3d.core.base.data.UV;	import away3d.core.base.data.Vertex;	import away3d.entities.Mesh;	use namespace arcane;		/**	* Class Weld removes the vertices that can be shared from one or more meshes<code>Weld</code>	*/	public class Weld{				private static var _delv:uint;				/**		*  Apply the welding code to a given ObjectContainer3D.		* @param	 	obj			ObjectContainer3D. The target Object3d object.		*/		public static function apply(obj:ObjectContainer3D):void		{			_delv = 0;			parse(obj);		}				/**		* returns howmany vertices were deleted during the welding operation.		*/		public static function get verticesRemovedCount():uint		{			return _delv;		}		 		private static function parse(obj:ObjectContainer3D):void		{			var child:ObjectContainer3D;			if(obj is Mesh && obj.numChildren == 0)				weld(Mesh(obj));				 			for(var i:uint = 0;i<obj.numChildren;++i){				child = obj.getChildAt(i);				parse(child);			}		}				private static function checkEntry(v:Vertex, vertices:Vector.<Number>, refIndex:uint):int		{						for(var i:uint = 0;i<vertices.length;i+=3){								if(refIndex == i) continue;								if(v.x == vertices[i])							if(v.y == vertices[i+1] && v.z == vertices[i+2]) return i/3;				 			}			 			return -1;		}				private static function weld(m:Mesh):void		{			var geometry:Geometry = m.geometry;			var geometries:Vector.<SubGeometry> = geometry.subGeometries;			var numSubGeoms:int = geometries.length;						var vertices:Vector.<Number>;			var indices:Vector.<uint>;			var uvs:Vector.<Number>;						var v:Vertex = new Vertex();			var uv:UV = new UV();						var nvertices:Vector.<Number>;			// TODO: not used			// var nnormals:Vector.<Number>;			var nindices:Vector.<uint>;			var nuvs:Vector.<Number>;						var vectors:Array = [];			 			var index:uint;			var indexuv:uint;			// TODO: not used			//var indexind:uint;						var nIndex:uint;			var nIndexuv:uint;			var nIndexind:uint;			var checkIndex:int;						var j : uint;			var i : uint;			var vecLength : uint;			var subGeom:SubGeometry;			 			for (i = 0; i < numSubGeoms; ++i){				subGeom = SubGeometry(geometries[i]);				vertices = subGeom.vertexData;				indices = subGeom.indexData;				uvs = subGeom.UVData;				vecLength = indices.length;				            	subGeom.autoDeriveVertexTangents = true;				subGeom.autoDeriveVertexNormals = true;								nvertices = new Vector.<Number>();				nindices = new Vector.<uint>();				nuvs = new Vector.<Number>();							vectors.push(nvertices,nindices,nuvs);								for (j = 0; j < vecLength;++j){					index = indices[j]*3;										v.x = vertices[index];					v.y = vertices[index+1];					v.z = vertices[index+2];										checkIndex = checkEntry(v, nvertices, index);					if( checkIndex == -1){												indexuv = indices[j]*2;						uv.u = uvs[indexuv];						uv.v = uvs[indexuv+1];											nindices[nIndexind++] = nvertices.length/3;						nvertices[nIndex++] = v.x;						nvertices[nIndex++] = v.y;						nvertices[nIndex++] = v.z;						nuvs[nIndexuv++] = uv.u;						nuvs[nIndexuv++] = uv.v;											} else {						nindices[nIndexind++] = checkIndex;					}				}								_delv += (vertices.length - nvertices.length)/3;			}									for (i = 0; i<vectors.length; i+=3){				subGeom = SubGeometry(geometries[i]); 								subGeom.updateVertexData(vectors[i]);				subGeom.updateIndexData(vectors[i+1]);				subGeom.updateUVData(vectors[i+2]);			}			 			vectors = null;		}		 	}}