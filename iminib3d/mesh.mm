/*
 *  mesh.mm
 *  iminib3d
 *
 *  Created by Simon Harrison.
 *  Copyright Si Design. All rights reserved.
 *
 */

#include "mesh.h"

#include "global.h"
#include "sprite.h"
#include "surface.h"
#include "texture.h"
#include "model.h"
#include "pick.h"
#include "geom.h"
#include "maths_helper.h"
#include "string_helper.h"

#include <iostream>
#include <vector>
#include <list>
#include <map>
using namespace std;

Mesh* Mesh::CopyEntity(Entity* parent_ent){

	if(parent_ent==NULL) parent_ent=Global::root_ent;

	// new mesh
	Mesh* mesh=new Mesh();
	
	// copy contents of child list before adding parent
	list<Entity*>::iterator it;
	for(it=child_list.begin();it!=child_list.end();it++){
		Entity* ent=*it;
		ent->CopyEntity(mesh);
	}
	
	// lists
		
	// add parent, add to list
	mesh->AddParent(*parent_ent);
	entity_list.push_back(mesh);

	// add to animate list
	if(anim_update){
		animate_list.push_back(mesh);
	}
	
	// add to collision entity list
	if(collision_type!=0){
		CollisionPair::ent_lists[collision_type].push_back(mesh);
	}
	
	// add to pick entity list
	if(pick_mode!=0){
		Pick::ent_list.push_back(mesh);
	}
	
	// update matrix
	if(mesh->parent){
		mesh->mat.Overwrite(mesh->parent->mat);
	}else{
		mesh->mat.LoadIdentity();
	}
	
	// copy entity info
			
	mesh->mat.Multiply(mat);
	
	mesh->px=px;
	mesh->py=py;
	mesh->pz=pz;
	mesh->sx=sx;
	mesh->sy=sy;
	mesh->sz=sz;
	mesh->rx=rx;
	mesh->ry=ry;
	mesh->rz=rz;
	mesh->qw=qw;
	mesh->qx=qx;
	mesh->qy=qy;
	mesh->qz=qz;
	
	mesh->name=name;
	mesh->class_name=class_name;
	mesh->hide=hide;
	mesh->order=order;
	mesh->auto_fade=auto_fade;
	mesh->fade_near=fade_near;
	mesh->fade_far=fade_far;
	
	mesh->brush=brush;
	
	mesh->anim=anim;
	mesh->anim_render=anim_render;
	mesh->anim_mode=anim_mode;
	mesh->anim_time=anim_time;
	mesh->anim_speed=anim_speed;
	mesh->anim_seq=anim_seq;
	mesh->anim_trans=anim_trans;
	mesh->anim_dir=anim_dir;
	mesh->anim_seqs_first=anim_seqs_first;
	mesh->anim_seqs_last=anim_seqs_last;
	mesh->no_seqs=no_seqs;
	mesh->anim_update=anim_update;
	mesh->anim_list=anim_list;

	mesh->cull_radius=cull_radius;
	mesh->radius_x=radius_x;
	mesh->radius_y=radius_y;
	mesh->box_x=box_x;
	mesh->box_y=box_y;
	mesh->box_z=box_z;
	mesh->box_w=box_w;
	mesh->box_h=box_h;
	mesh->box_d=box_d;
	mesh->collision_type=collision_type;
	mesh->pick_mode=pick_mode;
	mesh->obscurer=obscurer;

	// copy mesh info
	
	mesh->min_x=min_x;
	mesh->min_y=min_y;
	mesh->min_z=min_z;
	mesh->max_x=max_x;
	mesh->max_y=max_y;
	mesh->max_z=max_z;
	
	mesh->no_surfs=no_surfs;
	
	// copy surf list
	list<Surface*>::iterator it2;
	for(it2=surf_list.begin();it2!=surf_list.end();it2++){
	
		Surface* surf=*it2;
	
		Surface* new_surf=new Surface;
		mesh->surf_list.push_back(new_surf);
		
		new_surf->no_verts=surf->no_verts;
		new_surf->no_tris=surf->no_tris;
		
		// copy arrays
		new_surf->vert_coords=surf->vert_coords;
		new_surf->vert_norm=surf->vert_norm;
		new_surf->vert_tex_coords0=surf->vert_tex_coords0;
		new_surf->vert_tex_coords1=surf->vert_tex_coords1;
		new_surf->vert_col=surf->vert_col;
		new_surf->tris=surf->tris;

		// copy brush
        delete new_surf->brush; // delete first!
		new_surf->brush=surf->brush->Copy();

		new_surf->vert_array_size=surf->vert_array_size;
		new_surf->tri_array_size=surf->tri_array_size;
		new_surf->vmin=surf->vmin;
		new_surf->vmax=surf->vmax;
		
		new_surf->vbo_enabled=surf->vbo_enabled;
		new_surf->reset_vbo=-1; // (-1 = all)
		
	}
	
	// copy anim surf list
	for(it2=anim_surf_list.begin();it2!=anim_surf_list.end();it2++){
	
		Surface* surf=*it2;
	
		Surface* new_surf=new Surface;
		mesh->anim_surf_list.push_back(new_surf);
		
		new_surf->no_verts=surf->no_verts;

		// copy array
		new_surf->vert_coords=surf->vert_coords;

		// pointers to arrays
		new_surf->vert_bone1_no=surf->vert_bone1_no;
		new_surf->vert_bone2_no=surf->vert_bone2_no;
		new_surf->vert_bone3_no=surf->vert_bone3_no;
		new_surf->vert_bone4_no=surf->vert_bone4_no;
		new_surf->vert_weight1=surf->vert_weight1;
		new_surf->vert_weight2=surf->vert_weight2;
		new_surf->vert_weight3=surf->vert_weight3;
		new_surf->vert_weight4=surf->vert_weight4;
		
		new_surf->vert_array_size=surf->vert_array_size;
		new_surf->tri_array_size=surf->tri_array_size;
		new_surf->vmin=surf->vmin;
		new_surf->vmax=surf->vmax;
		
		new_surf->vbo_enabled=surf->vbo_enabled;
		new_surf->reset_vbo=-1; // (-1 = all)
		
	}
	
	mesh->c_col_tree=c_col_tree;

	mesh->reset_bounds=reset_bounds;

	mesh->no_bones=no_bones;
	CopyBonesList(mesh,mesh->bones);
	
	return mesh;

}

void Mesh::FreeEntity(){
	
	//cout << "Mesh::FreeEntity  name: " << name << "  class: " << class_name << endl;
	
	list<Surface*>::iterator surf_it;
	
	for(surf_it=surf_list.begin();surf_it!=surf_list.end();surf_it++){
		Surface* surf=*surf_it;
		delete surf;
	}
	surf_list.clear();
	
	for(surf_it=anim_surf_list.begin();surf_it!=anim_surf_list.end();surf_it++){
		Surface* anim_surf=*surf_it;
		delete anim_surf;
	}
	anim_surf_list.clear();
	
	vector<Bone*>::iterator bone_it;
	
	for(bone_it=bones.begin();bone_it!=bones.end();bone_it++){
		//Bone* bone=*bone_it;
		//delete bone;
	}
	bones.clear();

	delete c_col_tree;

	Entity::FreeEntity();
	
	delete this;
	
	return;

}

Mesh* Mesh::CreateMesh(Entity* parent_ent){

	if(parent_ent==NULL) parent_ent=Global::root_ent;
	
	Mesh* mesh=new Mesh();
	
	mesh->class_name="Mesh";
	
	mesh->AddParent(*parent_ent);
	entity_list.push_back(mesh);
	
	//update matrix
	if(mesh->parent!=0){
		mesh->mat.Overwrite(mesh->parent->mat);
		mesh->UpdateMat();
	}else{
		mesh->UpdateMat(true);
	}
	
	return mesh;
	
}

Surface* Mesh::CreateSurface(Brush* bru){

	Surface* surf=new Surface();
	surf_list.push_back(surf);
	
	no_surfs=no_surfs+1;
	
	if(bru!=NULL){
		delete surf->brush;
		surf->brush=bru->Copy();
	}

	// new mesh surface - update reset flags
	reset_bounds=true;
	reset_col_tree=true;

	return surf;

}

Mesh* Mesh::LoadMesh(string filename,Entity* parent_ent){

	if(parent_ent==NULL) parent_ent=Global::root_ent;

	if(Right(filename,4)==".3ds") filename=Replace(filename,".3ds",".b3d");

	Entity* ent=LoadAnimMesh(filename);
	ent->HideEntity();
	Mesh* mesh=dynamic_cast<Mesh*>(ent)->CollapseAnimMesh();
	ent->FreeEntity();
	mesh->class_name="Mesh";

	mesh->AddParent(*parent_ent);
	entity_list.push_back(mesh);
	
	//update matrix
	if(mesh->parent!=0){
		mesh->mat.Overwrite(mesh->parent->mat);
		mesh->UpdateMat();
	}else{
		mesh->UpdateMat(true);
	}

	return mesh;

}

Mesh* Mesh::LoadAnimMesh(string filename,Entity* parent_ent){
	
	if(parent_ent==NULL) parent_ent=Global::root_ent;
	
	if(Right(filename,4)==".3ds") filename=Replace(filename,".3ds",".b3d");

	return LoadAnimB3D(filename,parent_ent);

}

Mesh* Mesh::CreateQuad(Entity* parent_ent){
	
	Mesh* mesh=CreateMesh(parent_ent);
	
	Surface* surf=mesh->CreateSurface();
	
	surf->AddVertex(-1.0,-1.0,0.0);
	surf->AddVertex(-1.0, 1.0,0.0);
	surf->AddVertex( 1.0, 1.0,0.0);
	surf->AddVertex( 1.0,-1.0,0.0);

	surf->VertexNormal(0,0.0,0.0,-1.0);
	surf->VertexNormal(1,0.0,0.0,-1.0);
	surf->VertexNormal(2,0.0,0.0,-1.0);
	surf->VertexNormal(3,0.0,0.0,-1.0);
	
	surf->VertexTexCoords(0,0.0,1.0,0.0,0);
	surf->VertexTexCoords(1,0.0,0.0,0.0,0);
	surf->VertexTexCoords(2,1.0,0.0,0.0,0);
	surf->VertexTexCoords(3,1.0,1.0,0.0,0);

	surf->AddTriangle(0,1,2); // front
	surf->AddTriangle(0,2,3);

	return mesh;
	
}

/*
Mesh* Mesh::CreateCube(Entity* parent_ent){

  Mesh* m=CreateMesh(parent_ent);
	Surface* s=m->CreateSurface();
  
	static Vector norms[]={
		Vector(0,0,-1),Vector(1,0,0),Vector(0,0,1),
		Vector(-1,0,0),Vector(0,1,0),Vector(0,-1,0)
	};
	static Vector tex_coords[]={
		Vector(0,0,1),Vector(1,0,1),Vector(1,1,1),Vector(0,1,1)
	};
	static int verts[]={
		2,3,1,0,3,7,5,1,7,6,4,5,6,2,0,4,6,7,3,2,0,1,5,4
	};
	static Box box( Vector(-1,-1,-1),Vector(1,1,1) );
  
	b3dVertex v;
	b3dTriangle t;
	for( int k=0;k<24;k+=4 ){
		const Vector &normal=norms[k/4];
		for( int j=0;j<4;++j ){
			v.coords=box.corner( verts[k+j] );
			v.normal=normal;
			v.tex_coords[0][0]=v.tex_coords[1][0]=tex_coords[j].x;
			v.tex_coords[0][1]=v.tex_coords[1][1]=tex_coords[j].y;
			s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
		}
		t.verts[0]=k;t.verts[1]=k+1;t.verts[2]=k+2;s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
		t.verts[1]=k+2;t.verts[2]=k+3;s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
  
  m->UpdateNormals();
  
	return m;
}
*/

Mesh* Mesh::CreateCube(Entity* parent_ent){
	
	Mesh* mesh=CreateMesh(parent_ent);
	
	Surface* surf=mesh->CreateSurface();
	
	surf->AddVertex(-1.0,-1.0,-1.0);
	surf->AddVertex(-1.0, 1.0,-1.0);
	surf->AddVertex( 1.0, 1.0,-1.0);
	surf->AddVertex( 1.0,-1.0,-1.0);
	
	surf->AddVertex(-1.0,-1.0, 1.0);
	surf->AddVertex(-1.0, 1.0, 1.0);
	surf->AddVertex( 1.0, 1.0, 1.0);
	surf->AddVertex( 1.0,-1.0, 1.0);
	
	surf->AddVertex(-1.0,-1.0, 1.0);
	surf->AddVertex(-1.0, 1.0, 1.0);
	surf->AddVertex( 1.0, 1.0, 1.0);
	surf->AddVertex( 1.0,-1.0, 1.0);
	
	surf->AddVertex(-1.0,-1.0,-1.0);
	surf->AddVertex(-1.0, 1.0,-1.0);
	surf->AddVertex( 1.0, 1.0,-1.0);
	surf->AddVertex( 1.0,-1.0,-1.0);
	
	surf->AddVertex(-1.0,-1.0, 1.0);
	surf->AddVertex(-1.0, 1.0, 1.0);
	surf->AddVertex( 1.0, 1.0, 1.0);
	surf->AddVertex( 1.0,-1.0, 1.0);
	
	surf->AddVertex(-1.0,-1.0,-1.0);
	surf->AddVertex(-1.0, 1.0,-1.0);
	surf->AddVertex( 1.0, 1.0,-1.0);
	surf->AddVertex( 1.0,-1.0,-1.0);
	
	surf->VertexNormal(0,0.0,0.0,-1.0);
	surf->VertexNormal(1,0.0,0.0,-1.0);
	surf->VertexNormal(2,0.0,0.0,-1.0);
	surf->VertexNormal(3,0.0,0.0,-1.0);
	
	surf->VertexNormal(4,0.0,0.0,1.0);
	surf->VertexNormal(5,0.0,0.0,1.0);
	surf->VertexNormal(6,0.0,0.0,1.0);
	surf->VertexNormal(7,0.0,0.0,1.0);
	
	surf->VertexNormal(8,0.0,-1.0,0.0);
	surf->VertexNormal(9,0.0,1.0,0.0);
	surf->VertexNormal(10,0.0,1.0,0.0);
	surf->VertexNormal(11,0.0,-1.0,0.0);
	
	surf->VertexNormal(12,0.0,-1.0,0.0);
	surf->VertexNormal(13,0.0,1.0,0.0);
	surf->VertexNormal(14,0.0,1.0,0.0);
	surf->VertexNormal(15,0.0,-1.0,0.0);
	
	surf->VertexNormal(16,-1.0,0.0,0.0);
	surf->VertexNormal(17,-1.0,0.0,0.0);
	surf->VertexNormal(18,1.0,0.0,0.0);
	surf->VertexNormal(19,1.0,0.0,0.0);
	
	surf->VertexNormal(20,-1.0,0.0,0.0);
	surf->VertexNormal(21,-1.0,0.0,0.0);
	surf->VertexNormal(22,1.0,0.0,0.0);
	surf->VertexNormal(23,1.0,0.0,0.0);
	
	surf->VertexTexCoords(0,0.0,1.0,0.0,0);
	surf->VertexTexCoords(1,0.0,0.0,0.0,0);
	surf->VertexTexCoords(2,1.0,0.0,0.0,0);
	surf->VertexTexCoords(3,1.0,1.0,0.0,0);
	
	surf->VertexTexCoords(4,1.0,1.0,0.0,0);
	surf->VertexTexCoords(5,1.0,0.0,0.0,0);
	surf->VertexTexCoords(6,0.0,0.0,0.0,0);
	surf->VertexTexCoords(7,0.0,1.0,0.0,0);
	
	surf->VertexTexCoords(8,0.0,1.0,0.0,0);
	surf->VertexTexCoords(9,0.0,0.0,0.0,0);
	surf->VertexTexCoords(10,1.0,0.0,0.0,0);
	surf->VertexTexCoords(11,1.0,1.0,0.0,0);
	
	surf->VertexTexCoords(12,0.0,0.0,0.0,0);
	surf->VertexTexCoords(13,0.0,1.0,0.0,0);
	surf->VertexTexCoords(14,1.0,1.0,0.0,0);
	surf->VertexTexCoords(15,1.0,0.0,0.0,0);
	
	surf->VertexTexCoords(16,0.0,1.0,0.0,0);
	surf->VertexTexCoords(17,0.0,0.0,0.0,0);
	surf->VertexTexCoords(18,1.0,0.0,0.0,0);
	surf->VertexTexCoords(19,1.0,1.0,0.0,0);
	
	surf->VertexTexCoords(20,1.0,1.0,0.0,0);
	surf->VertexTexCoords(21,1.0,0.0,0.0,0);
	surf->VertexTexCoords(22,0.0,0.0,0.0,0);
	surf->VertexTexCoords(23,0.0,1.0,0.0,0);
	
	surf->VertexTexCoords(0,0.0,1.0,0.0,1);
	surf->VertexTexCoords(1,0.0,0.0,0.0,1);
	surf->VertexTexCoords(2,1.0,0.0,0.0,1);
	surf->VertexTexCoords(3,1.0,1.0,0.0,1);
	
	surf->VertexTexCoords(4,1.0,1.0,0.0,1);
	surf->VertexTexCoords(5,1.0,0.0,0.0,1);
	surf->VertexTexCoords(6,0.0,0.0,0.0,1);
	surf->VertexTexCoords(7,0.0,1.0,0.0,1);
	
	surf->VertexTexCoords(8,0.0,1.0,0.0,1);
	surf->VertexTexCoords(9,0.0,0.0,0.0,1);
	surf->VertexTexCoords(10,1.0,0.0,0.0,1);
	surf->VertexTexCoords(11,1.0,1.0,0.0,1);
	
	surf->VertexTexCoords(12,0.0,0.0,0.0,1);
	surf->VertexTexCoords(13,0.0,1.0,0.0,1);
	surf->VertexTexCoords(14,1.0,1.0,0.0,1);
	surf->VertexTexCoords(15,1.0,0.0,0.0,1);
	
	surf->VertexTexCoords(16,0.0,1.0,0.0,1);
	surf->VertexTexCoords(17,0.0,0.0,0.0,1);
	surf->VertexTexCoords(18,1.0,0.0,0.0,1);
	surf->VertexTexCoords(19,1.0,1.0,0.0,1);
	
	surf->VertexTexCoords(20,1.0,1.0,0.0,1);
	surf->VertexTexCoords(21,1.0,0.0,0.0,1);
	surf->VertexTexCoords(22,0.0,0.0,0.0,1);
	surf->VertexTexCoords(23,0.0,1.0,0.0,1);
	
	surf->AddTriangle(0,1,2); // front
	surf->AddTriangle(0,2,3);
	surf->AddTriangle(6,5,4); // back
	surf->AddTriangle(7,6,4);
	surf->AddTriangle(6+8,5+8,1+8); // top
	surf->AddTriangle(2+8,6+8,1+8);
	surf->AddTriangle(0+8,4+8,7+8); // bottom
	surf->AddTriangle(0+8,7+8,3+8);
	surf->AddTriangle(6+16,2+16,3+16); // right
	surf->AddTriangle(7+16,6+16,3+16);
	surf->AddTriangle(0+16,1+16,5+16); // left
	surf->AddTriangle(0+16,5+16,4+16);
	
	return mesh;
	
}

//MeshModel *MeshUtil::createSphere( const Brush &b,int segs ){
Mesh* Mesh::CreateSphere(int segments,Entity* parent_ent){

  if(segments<3 || segments>100) return NULL;
  
	int h_segs=segments*2,v_segs=segments;

  Mesh* m=CreateMesh(parent_ent);
	Surface* s=m->CreateSurface();
    
	b3dVertex v;
	b3dTriangle t;
    
	v.coords=v.normal=Vector(0,1,0);
	int k;
	for( k=0;k<h_segs;++k ){
		v.tex_coords[0][0]=v.tex_coords[1][0]=(k+.5f)/h_segs;
		v.tex_coords[0][1]=v.tex_coords[1][1]=0;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	for( k=1;k<v_segs;++k ){
		float pitch=k*PI/v_segs-HALFPI;
		for( int j=0;j<=h_segs;++j ){
			float yaw=(j%h_segs)*TWOPI/h_segs;
			v.coords=v.normal=rotationMMatrix( pitch,yaw,0 ).k;
			v.tex_coords[0][0]=v.tex_coords[1][0]=float(j)/float(h_segs);
			v.tex_coords[0][1]=v.tex_coords[1][1]=float(k)/float(v_segs);
			s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
		}
	}
	v.coords=v.normal=Vector(0,-1,0);
	for( k=0;k<h_segs;++k ){
		v.tex_coords[0][0]=v.tex_coords[1][0]=(k+.5f)/h_segs;
		v.tex_coords[0][1]=v.tex_coords[1][1]=1;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	for( k=0;k<h_segs;++k ){
		t.verts[0]=k;
		t.verts[1]=t.verts[0]+h_segs+1;
		t.verts[2]=t.verts[1]-1;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
	for( k=1;k<v_segs-1;++k ){
		for( int j=0;j<h_segs;++j ){
			t.verts[0]=k*(h_segs+1)+j-1;
			t.verts[1]=t.verts[0]+1;
			t.verts[2]=t.verts[1]+h_segs+1;
			s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
			t.verts[1]=t.verts[2];
			t.verts[2]=t.verts[1]-1;
			s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
		}
	}
	for( k=0;k<h_segs;++k ){
		t.verts[0]=(h_segs+1)*(v_segs-1)+k-1;
		t.verts[1]=t.verts[0]+1;
		t.verts[2]=t.verts[1]+h_segs;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
    
  m->UpdateNormals();
	return m;
}

// old CreateSphere - creates roughly x3-4 more vertices than above CreateSphere

/*
Mesh* Mesh::CreateSphere(int segments,Entity* parent_ent){

	if(segments<3 || segments>100) return NULL;

	Mesh* thissphere=CreateMesh(parent_ent);
	Surface* thissurf=thissphere->CreateSurface();

	float div=360.0/(segments*2);
	float height=1.0;
	float upos=1.0;
	float udiv=1.0/(segments*2);
	float vdiv=1.0/segments;
	float RotAngle=90;

	if(segments<3){ // diamond shape - no center strips

		for(int i=1;i<=segments*2;i++){
			int np=thissurf->AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);//northpole
			int sp=thissurf->AddVertex(0.0,-height,0.0,upos-(udiv/2.0),1);//southpole
			float XPos=-cosdeg(RotAngle);
			float ZPos=sindeg(RotAngle);
			int v0=thissurf->AddVertex(XPos,0,ZPos,upos,0.5);
			RotAngle=RotAngle+div;
			if(RotAngle>=360.0) RotAngle=RotAngle-360.0;
			XPos=-cosdeg(RotAngle);
			ZPos=sindeg(RotAngle);
			upos=upos-udiv;
			int v1=thissurf->AddVertex(XPos,0,ZPos,upos,0.5);
			thissurf->AddTriangle(np,v0,v1);
			thissurf->AddTriangle(v1,v0,sp);
		}
		
	}

	if(segments>2){

		// poles first
		for(int i=1;i<=segments*2;i++){

			int np=thissurf->AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);//northpole
			int sp=thissurf->AddVertex(0.0,-height,0.0,upos-(udiv/2.0),1);//southpole

			float YPos=cosdeg(div);

			float XPos=-cosdeg(RotAngle)*(sindeg(div));
			float ZPos=sindeg(RotAngle)*(sindeg(div));

			int v0t=thissurf->AddVertex(XPos,YPos,ZPos,upos,vdiv);
			int v0b=thissurf->AddVertex(XPos,-YPos,ZPos,upos,1-vdiv);

			RotAngle=RotAngle+div;

			XPos=-cosdeg(RotAngle)*(sindeg(div));
			ZPos=sindeg(RotAngle)*(sindeg(div));

			upos=upos-udiv;

			int v1t=thissurf->AddVertex(XPos,YPos,ZPos,upos,vdiv);
			int v1b=thissurf->AddVertex(XPos,-YPos,ZPos,upos,1-vdiv);

			thissurf->AddTriangle(np,v0t,v1t);
			thissurf->AddTriangle(v1b,v0b,sp);

		}

		// then center strips

		upos=1.0;
		RotAngle=90;
		for(int i=1;i<=segments*2;i++){

			float mult=1;
			float YPos=cosdeg(div*(mult));
			float YPos2=cosdeg(div*(mult+1.0));
			float Thisvdiv=vdiv;
			
			for(int j=1;j<=segments-2;j++){

				float XPos=-cosdeg(RotAngle)*(sindeg(div*(mult)));
				float ZPos=sindeg(RotAngle)*(sindeg(div*(mult)));

				float XPos2=-cosdeg(RotAngle)*(sindeg(div*(mult+1.0)));
				float ZPos2=sindeg(RotAngle)*(sindeg(div*(mult+1.0)));

				int v0t=thissurf->AddVertex(XPos,YPos,ZPos,upos,Thisvdiv);
				int v0b=thissurf->AddVertex(XPos2,YPos2,ZPos2,upos,Thisvdiv+vdiv);

				// 2nd tex coord set
				thissurf->VertexTexCoords(v0t,upos,Thisvdiv,0.0,1);
				thissurf->VertexTexCoords(v0b,upos,Thisvdiv+vdiv,0.0,1);

				float tempRotAngle=RotAngle+div;

				XPos=-cosdeg(tempRotAngle)*(sindeg(div*(mult)));
				ZPos=sindeg(tempRotAngle)*(sindeg(div*(mult)));
	
				XPos2=-cosdeg(tempRotAngle)*(sindeg(div*(mult+1.0)));
				ZPos2=sindeg(tempRotAngle)*(sindeg(div*(mult+1.0)));			

				float temp_upos=upos-udiv;

				int v1t=thissurf->AddVertex(XPos,YPos,ZPos,temp_upos,Thisvdiv);
				int v1b=thissurf->AddVertex(XPos2,YPos2,ZPos2,temp_upos,Thisvdiv+vdiv);
	
				// 2nd tex coord set
				thissurf->VertexTexCoords(v1t,temp_upos,Thisvdiv,0.0,1);
				thissurf->VertexTexCoords(v1b,temp_upos,Thisvdiv+vdiv,0.0,1);

				thissurf->AddTriangle(v1t,v0t,v0b);
				thissurf->AddTriangle(v1b,v1t,v0b);

				Thisvdiv=Thisvdiv+vdiv;		
				mult=mult+1;
				YPos=cosdeg(div*(mult));
				YPos2=cosdeg(div*(mult+1.0));

			}
			
			upos=upos-udiv;
			RotAngle=RotAngle+div;
	
		}

	}

	thissphere->UpdateNormals();
	return thissphere; 

}
*/

Mesh* Mesh::CreateCylinder(int segs,int solid,Entity* parent_ent){
  
  if(segs<3 || segs>100) return NULL;
  
	Mesh *m=CreateMesh(parent_ent);
  Surface* s=m->CreateSurface();
  
	b3dVertex v;
	b3dTriangle t;

	int k;
	for( k=0;k<=segs;++k ){
		float yaw=(k%segs)*TWOPI/segs;
		v.coords=rotationMMatrix( 0,yaw,0 ).k;
		v.coords.y=1;
		v.normal=Vector(v.coords.x,0,v.coords.z);
		v.tex_coords[0][0]=v.tex_coords[1][0]=float(k)/segs;
		v.tex_coords[0][1]=v.tex_coords[1][1]=0;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
		v.coords.y=-1;
		v.tex_coords[0][0]=v.tex_coords[1][0]=float(k)/segs;
		v.tex_coords[0][1]=v.tex_coords[1][1]=1;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	for( k=0;k<segs;++k ){
		t.verts[0]=k*2;
		t.verts[1]=t.verts[0]+2;
		t.verts[2]=t.verts[1]+1;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
		t.verts[1]=t.verts[2];
		t.verts[2]=t.verts[1]-2;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
  
	if( !solid ) return m;
  
	s=m->CreateSurface();
  
	for( k=0;k<segs;++k ){
		float yaw=k*TWOPI/segs;
		v.coords=rotationMMatrix( 0,yaw,0 ).k;
		v.coords.y=1;v.normal=Vector(0,1,0);
		v.tex_coords[0][0]=v.tex_coords[1][0]=v.coords.x*.5f+.5f;
		v.tex_coords[0][1]=v.tex_coords[1][1]=v.coords.z*.5f+.5f;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
		v.coords.y=-1;v.normal=Vector( 0,-1,0 );
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	for( k=2;k<segs;++k ){
		t.verts[0]=0;
		t.verts[1]=k*2;
		t.verts[2]=(k-1)*2;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
		t.verts[0]=1;
		t.verts[1]=(k-1)*2+1;
		t.verts[2]=k*2+1;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
  
	m->UpdateNormals();
 
  return m;
}
 
/*
Mesh* Mesh::CreateCylinder(int verticalsegments,int solid,Entity* parent_ent){

	int ringsegments=0; // default?

	int tr=0,tl=0,br=0,bl=0;// 		side of cylinder
	int ts0=0,ts1=0,newts=0;// 	top side vertexs
	int bs0=0,bs1=0,newbs=0;// 	bottom side vertexs
	if(verticalsegments<3 || verticalsegments>100) return NULL;
	if(ringsegments<0 || ringsegments>100) return NULL;
	
	Mesh* thiscylinder=Mesh::CreateMesh(parent_ent);
	Surface* thissurf=thiscylinder->CreateSurface();
	Surface* thissidesurf=NULL;
	if(solid==true){
		thissidesurf=thiscylinder->CreateSurface();
	}
	float div=float(360.0/(verticalsegments));

	float height=1.0;
	float ringSegmentHeight=(height*2.0)/(ringsegments+1);
	float upos=1.0;
	float udiv=float(1.0/(verticalsegments));
	float vdiv=float(1.0/(ringsegments+1));

	float SideRotAngle=90.0;

	// re-diminsion arrays to hold needed memory.
	// this is used just for helping to build the ring segments...

	int* tRing=new int[verticalsegments+1];
	int* bRing=new int[verticalsegments+1];

	// render end caps if solid
	if(solid==true){
	
		float XPos=-cosdeg(SideRotAngle);
		float ZPos=sindeg(SideRotAngle);

		ts0=thissidesurf->AddVertex(XPos,height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		bs0=thissidesurf->AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		
		// 2nd tex coord set
		thissidesurf->VertexTexCoords(ts0,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
		thissidesurf->VertexTexCoords(bs0,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);

		SideRotAngle=SideRotAngle+div;

		XPos=-cosdeg(SideRotAngle);
		ZPos=sindeg(SideRotAngle);
		
		ts1=thissidesurf->AddVertex(XPos,height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		bs1=thissidesurf->AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
	
		// 2nd tex coord set
		thissidesurf->VertexTexCoords(ts1,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
		thissidesurf->VertexTexCoords(bs1,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
		
		for(int i=1;i<=verticalsegments-2;i++){
			SideRotAngle=SideRotAngle+div;

			XPos=-cosdeg(SideRotAngle);
			ZPos=sindeg(SideRotAngle);
			
			newts=thissidesurf->AddVertex(XPos,height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
			newbs=thissidesurf->AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
			
			// 2nd tex coord set
			thissidesurf->VertexTexCoords(newts,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
			thissidesurf->VertexTexCoords(newbs,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1);
			
			thissidesurf->AddTriangle(ts0,ts1,newts);
			thissidesurf->AddTriangle(newbs,bs1,bs0);
		
			if(i<(verticalsegments-2)){
				ts1=newts;
				bs1=newbs;
			}
			
		}
	}

	// -----------------------
	// middle part of cylinder
	float thisHeight=height;
	
	// top ring first		
	SideRotAngle=90.0;
	float XPos=-cosdeg(SideRotAngle);
	float ZPos=sindeg(SideRotAngle);
	float thisUPos=upos;
	float thisVPos=0.0;
	tRing[0]=thissurf->AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);	
	thissurf->VertexTexCoords(tRing[0],thisUPos,thisVPos,0.0,1.0); // 2nd tex coord set
	for(int i=0;i<=verticalsegments-1;i++){
		SideRotAngle=SideRotAngle+div;
		XPos=-cosdeg(SideRotAngle);
		ZPos=sindeg(SideRotAngle);
		thisUPos=thisUPos-udiv;
		tRing[i+1]=thissurf->AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
		thissurf->VertexTexCoords(tRing[i+1],thisUPos,thisVPos,0.0,1.0); // 2nd tex coord set
	}	
	
	for(int ring=0;ring<=ringsegments;ring++){

		// decrement vertical segment
		thisHeight=thisHeight-ringSegmentHeight;
		
		// now bottom ring
		SideRotAngle=90;
		XPos=-cosdeg(SideRotAngle);
		ZPos=sindeg(SideRotAngle);
		thisUPos=upos;
		thisVPos=thisVPos+vdiv;
		bRing[0]=thissurf->AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
		thissurf->VertexTexCoords(bRing[0],thisUPos,thisVPos,0.0,1.0); // 2nd tex coord set
		for(int i=0;i<=verticalsegments-1;i++){
			SideRotAngle=SideRotAngle+div;
			XPos=-cosdeg(SideRotAngle);
			ZPos=sindeg(SideRotAngle);
			thisUPos=thisUPos-udiv;
			bRing[i+1]=thissurf->AddVertex(XPos,thisHeight,ZPos,thisUPos,thisVPos);
			thissurf->VertexTexCoords(bRing[i+1],thisUPos,thisVPos,0.0,1.0); // 2nd tex coord set
		}
		
		// Fill in ring segment sides with triangles
		for(int v=1;v<=verticalsegments;v++){
			tl=tRing[v];
			tr=tRing[v-1];
			bl=bRing[v];
			br=bRing[v-1];
			
			thissurf->AddTriangle(tl,tr,br);
			thissurf->AddTriangle(bl,tl,br);
		}
		
		// make bottom ring segment the top ring segment for the next loop.
		for(int v=0;v<=verticalsegments;v++){
			tRing[v]=bRing[v];
		}	
	}
	
	delete [] tRing;
	delete [] bRing;
			
	thiscylinder->UpdateNormals();
	return thiscylinder;
	
}
*/

Mesh* Mesh::CreateCone(int segs,int solid,Entity* parent_ent){
  
	if(segs<3 || segs>100) return NULL;
	
	Mesh* m=Mesh::CreateMesh(parent_ent);
	Surface* s=m->CreateSurface();
 
	b3dVertex v;
	b3dTriangle t;
  
	int k;
	v.coords=v.normal=Vector(0,1,0);
	for( k=0;k<segs;++k ){
		v.tex_coords[0][0]=v.tex_coords[1][0]=(k+.5f)/segs;
		v.tex_coords[0][1]=v.tex_coords[1][1]=0;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	for( k=0;k<=segs;++k ){
		float yaw=(k%segs)*TWOPI/segs;
		v.coords=yawMMatrix( yaw ).k;v.coords.y=-1;
		v.normal=Vector( v.coords.x,0,v.coords.z );
		v.tex_coords[0][0]=v.tex_coords[1][0]=float(k)/segs;
		v.tex_coords[0][1]=v.tex_coords[1][1]=1;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	for( k=0;k<segs;++k ){
		t.verts[0]=k;
		t.verts[1]=k+segs+1;
		t.verts[2]=k+segs;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
	if( !solid ) return m;
	s=m->CreateSurface();
	for( k=0;k<segs;++k ){
		float yaw=k*TWOPI/segs;
		v.coords=yawMMatrix( yaw ).k;v.coords.y=-1;
		v.normal=Vector( v.coords.x,0,v.coords.z );
		v.tex_coords[0][0]=v.tex_coords[1][0]=v.coords.x*.5f+.5f;
		v.tex_coords[0][1]=v.tex_coords[1][1]=v.coords.z*.5f+.5f;
		s->AddVertex( v.coords.x, v.coords.y, v.coords.z, v.tex_coords[0][0], v.tex_coords[0][1], 0.0 );
	}
	t.verts[0]=0;
	for( k=2;k<segs;++k ){
		t.verts[1]=k-1;
		t.verts[2]=k;
		s->AddTriangle( t.verts[0], t.verts[1], t.verts[2] );
	}
  
  m->UpdateNormals();
  
	return m;
}
 
/*
Mesh* Mesh::CreateCone(int segments,int solid,Entity* parent_ent){

	int top=0,br=0,bl=0; // side of cone
	int bs0=0,bs1=0,newbs=0; // bottom side vertices
	
	if(segments<3 || segments>100) return NULL;
	
	Mesh* thiscone=Mesh::CreateMesh(parent_ent);
	Surface* thissurf=thiscone->CreateSurface();
	Surface* thissidesurf=NULL;
	if(solid==true){
		thissidesurf=thiscone->CreateSurface();
	}
	float div=float(360.0/segments);

	float height=1.0;
	float upos=1.0;
	float udiv=float(1.0/(segments));
	float RotAngle=90.0;

	// first side
	float XPos=-cosdeg(RotAngle);
	float ZPos=sindeg(RotAngle);

	top=thissurf->AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);
	br=thissurf->AddVertex(XPos,-height,ZPos,upos,1);
	
	// 2nd tex coord set
	thissurf->VertexTexCoords(top,upos-(udiv/2.0),0,0.0,1);
	thissurf->VertexTexCoords(br,upos,1,0.0,1);

	if(solid==true) bs0=thissidesurf->AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
	if(solid==true) thissidesurf->VertexTexCoords(bs0,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1); // 2nd tex coord set

	RotAngle=RotAngle+div;

	XPos=-cosdeg(RotAngle);
	ZPos=sindeg(RotAngle);
				
	bl=thissurf->AddVertex(XPos,-height,ZPos,upos-udiv,1);
	thissurf->VertexTexCoords(bl,upos-udiv,1,0.0,1); // 2nd tex coord set	

	if(solid==true) bs1=thissidesurf->AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
	if(solid==true) thissidesurf->VertexTexCoords(bs1,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1); // 2nd tex coord set
	
	thissurf->AddTriangle(bl,top,br);

	// rest of sides
	for(int i=1;i<=(segments-1);i++){
		br=bl;
		upos=upos-udiv;
		top=thissurf->AddVertex(0.0,height,0.0,upos-(udiv/2.0),0);
		thissurf->VertexTexCoords(top,upos-(udiv/2.0),0,0.0,1); // 2nd tex coord set
	
		RotAngle=RotAngle+div;

		XPos=-cosdeg(RotAngle);
		ZPos=sindeg(RotAngle);
		
		bl=thissurf->AddVertex(XPos,-height,ZPos,upos-udiv,1);
		thissurf->VertexTexCoords(bl,upos-udiv,1,0.0,1); // 2nd tex coord set

		if(solid==true) newbs=thissidesurf->AddVertex(XPos,-height,ZPos,XPos/2.0+0.5,ZPos/2.0+0.5);
		if(solid==true) thissidesurf->VertexTexCoords(newbs,XPos/2.0+0.5,ZPos/2.0+0.5,0.0,1); // 2nd tex coord set
	
		thissurf->AddTriangle(bl,top,br);
		
		if(solid==true){
			thissidesurf->AddTriangle(newbs,bs1,bs0);
		
			if(i<(segments-1)){
				bs1=newbs;
			}
		}
	}
	
	thiscone->UpdateNormals();
	return thiscone;
	
}
*/

Mesh* Mesh::CopyMesh(Entity* parent_ent){

	Mesh* mesh=Mesh::CreateMesh(parent_ent);
	
	AddMesh(mesh);
	return mesh;

}

void Mesh::AddMesh(Mesh* mesh2){

	//int cs2=mesh2->CountSurfaces();

	for(int s1=1;s1<=CountSurfaces();s1++){

		Surface* surf1=GetSurface(s1);
			
		// if surface is empty, don't add it
		if(surf1->CountVertices()==0 and surf1->CountTriangles()==0) continue;
		
		int new_surf=true;

		for(int s2=1;s2<=mesh2->CountSurfaces();s2++){
		//for(int s2=1;s2<=cs2;s2++){

			Surface* surf2=mesh2->GetSurface(s2);
			
			int no_verts2=surf2->CountVertices();

			// if brushes properties are the same, add surf1 verts and tris to surf2
			if(Brush::CompareBrushes(surf1->brush,surf2->brush)==true){

				// add vertices
			
				for(int v=0;v<=surf1->CountVertices()-1;v++){
	
					float vx=surf1->VertexX(v);
					float vy=surf1->VertexY(v);
					float vz=surf1->VertexZ(v);
					float vr=surf1->VertexRed(v);
					float vg=surf1->VertexGreen(v);
					float vb=surf1->VertexBlue(v);
					float va=surf1->VertexAlpha(v);
					float vnx=surf1->VertexNX(v);
					float vny=surf1->VertexNY(v);
					float vnz=surf1->VertexNZ(v);
					float vu0=surf1->VertexU(v,0);
					float vv0=surf1->VertexV(v,0);
					float vw0=surf1->VertexW(v,0);
					float vu1=surf1->VertexU(v,1);
					float vv1=surf1->VertexV(v,1);
					float vw1=surf1->VertexW(v,1);
					
					int v2=surf2->AddVertex(vx,vy,vz);
					surf2->VertexColor(v2,vr,vg,vb,va);
					surf2->VertexNormal(v2,vnx,vny,vnz);
					surf2->VertexTexCoords(v2,vu0,vv0,vw0,0);
					surf2->VertexTexCoords(v2,vu1,vv1,vw1,1);

				}
	
				// add triangles
			
				for(int t=0;t<=surf1->CountTriangles()-1;t++){
	
					int v0=surf1->TriangleVertex(t,0)+no_verts2;
					int v1=surf1->TriangleVertex(t,1)+no_verts2;
					int v2=surf1->TriangleVertex(t,2)+no_verts2;
					
					surf2->AddTriangle(v0,v1,v2);

				}
				
				// mesh shape has changed - update reset flags
				surf2->reset_vbo=-1; // (-1 = all)

				new_surf=false;
				break;
	
			}
			
		}
		
		// add new surface
		
		if(new_surf==true){

			Surface* surf=mesh2->CreateSurface();
			
			// add vertices
		
			for(int v=0;v<=surf1->CountVertices()-1;v++){

				float vx=surf1->VertexX(v);
				float vy=surf1->VertexY(v);
				float vz=surf1->VertexZ(v);
				float vr=surf1->VertexRed(v);
				float vg=surf1->VertexGreen(v);
				float vb=surf1->VertexBlue(v);
				float va=surf1->VertexAlpha(v);
				float vnx=surf1->VertexNX(v);
				float vny=surf1->VertexNY(v);
				float vnz=surf1->VertexNZ(v);
				float vu0=surf1->VertexU(v,0);
				float vv0=surf1->VertexV(v,0);
				float vw0=surf1->VertexW(v,0);
				float vu1=surf1->VertexU(v,1);
				float vv1=surf1->VertexV(v,1);
				float vw1=surf1->VertexW(v,1);
								
				int v2=surf->AddVertex(vx,vy,vz);
				surf->VertexColor(v2,vr,vg,vb,va);
				surf->VertexNormal(v2,vnx,vny,vnz);
				surf->VertexTexCoords(v2,vu0,vv0,vw0,0);
				surf->VertexTexCoords(v2,vu1,vv1,vw1,1);

			}

			// add triangles
		
			for(int t=0;t<=surf1->CountTriangles()-1;t++){

				int v0=surf1->TriangleVertex(t,0);
				int v1=surf1->TriangleVertex(t,1);
				int v2=surf1->TriangleVertex(t,2);
				
				surf->AddTriangle(v0,v1,v2);

			}
			
			// copy brush
			
			if(surf1->brush){
			
				surf->brush=surf1->brush->Copy();
				
			}
			
			// mesh shape has changed - update reset flags
			surf->reset_vbo=-1; // (-1 = all)
		
		}
						
	}
	
	// mesh shape has changed - update reset flags
	mesh2->reset_bounds=true;
	mesh2->reset_col_tree=true;
	
}

void Mesh::FlipMesh(){

	for(int s=1;s<=no_surfs;s++){
	
		Surface* surf=GetSurface(s);
	
		// flip triangle vertex order
		for(int t=1;t<=surf->no_tris;t++){
		
			int i0=t*3-3;
			//int i1=t*3-2;
			int i2=t*3-1;
		
			int v0=surf->tris[i0];
			//int v1=surf->tris[i1];
			int v2=surf->tris[i2];
	
			surf->tris[i0]=v2;
			//surf->tris[i1];
			surf->tris[i2]=v0;
	
		}
		
		// flip vertex normals
		for(int v=0;v<=surf->no_verts-1;v++){
		
			surf->vert_norm[v*3]=surf->vert_norm[v*3]*-1; // x
			surf->vert_norm[(v*3)+1]=surf->vert_norm[(v*3)+1]*-1; // y
			surf->vert_norm[(v*3)+2]=surf->vert_norm[(v*3)+2]*-1; // z

		}
		
		// mesh shape has changed - update reset flag
		surf->reset_vbo=surf->reset_vbo|4|16;
	
	}
	
	// mesh shape has changed - update reset flag
	reset_col_tree=true;
		
}
		
void Mesh::PaintMesh(Brush* bru){

	for(int s=1;s<=CountSurfaces();s++){
	
		Surface* surf=GetSurface(s);

		//if(surf->brush==0) surf->brush=new Brush;
		
		surf->brush->no_texs=bru->no_texs;
		surf->brush->name=bru->name;
		surf->brush->red=bru->red;
		surf->brush->green=bru->green;
		surf->brush->blue=bru->blue;
		surf->brush->alpha=bru->alpha;
		surf->brush->shine=bru->shine;
		surf->brush->blend=bru->blend;
		surf->brush->fx=bru->fx;
		for(int i=0;i<=7;i++){
			surf->brush->tex[i]=bru->tex[i];
		}

	}

}

void Mesh::MeshColor(float r,float g,float b,float a){

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		surf->SurfaceColor(r,g,b,a);
						
	}
	
}


void Mesh::MeshColor(float r,float g,float b){

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		surf->SurfaceColor(r,g,b);
						
	}
	
}

void Mesh::MeshRed(float r){

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		surf->SurfaceRed(r);
						
	}
	
}

void Mesh::MeshGreen(float g){

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		surf->SurfaceGreen(g);
						
	}
	
}

void Mesh::MeshBlue(float b){

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		surf->SurfaceBlue(b);
						
	}
	
}

void Mesh::MeshAlpha(float a){

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		surf->SurfaceAlpha(a);
						
	}
	
}

void Mesh::FitMesh(float x,float y,float z,float width,float height,float depth,int uniform){

	// if uniform=true than adjust fitmesh dimensions
	
	if(uniform==true){
					
		float wr=MeshWidth()/width;
		float hr=MeshHeight()/height;
		float dr=MeshDepth()/depth;
	
		if(wr>=hr && wr>=dr){

			y=y+((height-(MeshHeight()/wr))/2.0);
			z=z+((depth-(MeshDepth()/wr))/2.0);
			
			height=MeshHeight()/wr;
			depth=MeshDepth()/wr;
		
		}else if(hr>dr){
		
			x=x+((width-(MeshWidth()/hr))/2.0);
			z=z+((depth-(MeshDepth()/hr))/2.0);
		
			width=MeshWidth()/hr;
			depth=MeshDepth()/hr;
					
		}else{
		
			x=x+((width-(MeshWidth()/dr))/2.0);
			y=y+((height-(MeshHeight()/dr))/2.0);
		
			width=MeshWidth()/dr;
			height=MeshHeight()/dr;
							
		}

	}
	
	// old to new dimensions ratio, used to update mesh normals
	float wr=MeshWidth()/width;
	float hr=MeshHeight()/height;
	float dr=MeshDepth()/depth;
	
	// find min/max dimensions

	float minx=999999999;
	float miny=999999999;
	float minz=999999999;
	float maxx=-999999999;
	float maxy=-999999999;
	float maxz=-999999999;

	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		for(int v=0;v<=surf->CountVertices()-1;v++){
	
			float vx=surf->VertexX(v);
			float vy=surf->VertexY(v);
			float vz=surf->VertexZ(v);
			
			if(vx<minx) minx=vx;
			if(vy<miny) miny=vy;
			if(vz<minz) minz=vz;
			
			if(vx>maxx) maxx=vx;
			if(vy>maxy) maxy=vy;
			if(vz>maxz) maxz=vz;

		}
						
	}
	
	for(int s=1;s<=CountSurfaces();s++){
		
		Surface* surf=GetSurface(s);
			
		for(int v=0;v<=surf->CountVertices()-1;v++){
	
			// update vertex positions
	
			float vx=surf->VertexX(v);
			float vy=surf->VertexY(v);
			float vz=surf->VertexZ(v);
							
			float mx=maxx-minx;
			float my=maxy-miny;
			float mz=maxz-minz;
			
			float ux,uy,uz;
			
			if(mx<0.0001 && mx>-0.0001){
				ux=0.0;
			}else{
				ux=(vx-minx)/mx;
			}
			
			if(my<0.0001 && my>-0.0001){
				uy=0.0;
			}else{
				uy=(vy-miny)/my;
			}
			
			if(mz<0.0001 && mz>-0.0001){
				uz=0.0;
			}else{
				uz=(vz-minz)/mz;
			}
									
			vx=x+(ux*width);
			vy=y+(uy*height);
			vz=z+(uz*depth);
			
			surf->VertexCoords(v,vx,vy,vz);
			
			// update normals

			float nx=surf->VertexNX(v);
			float ny=surf->VertexNY(v);
			float nz=surf->VertexNZ(v);
			
			nx=nx*wr;
			ny=ny*hr;
			nz=nz*dr;
			
			surf->VertexNormal(v,nx,ny,nz);

		}
		
		// mesh shape has changed - update reset flag
		surf->reset_vbo=surf->reset_vbo|1|4;

	}
	
	// mesh shape has changed - update reset flags
	reset_bounds=true;
	reset_col_tree=true;
	
}

void Mesh::ScaleMesh(float sx,float sy,float sz){
	
	for(int s=1;s<=CountSurfaces();s++){
	
		Surface* surf=GetSurface(s);
			
		for(int v=0;v<=surf->no_verts-1;v++){
	
			surf->vert_coords[v*3]*=sx;
			surf->vert_coords[v*3+1]*=sy;
			surf->vert_coords[v*3+2]*=sz;

		}
		
		// mesh shape has changed - update reset flag
		surf->reset_vbo=surf->reset_vbo|1;
			
	}
	
	// mesh shape has changed - update reset flags
	reset_bounds=true;
	reset_col_tree=true;

}

void Mesh::RotateMesh(float pitch,float yaw,float roll){

	pitch=-pitch;
	
	Matrix mat;
	mat.LoadIdentity();
	mat.Rotate(pitch,yaw,roll);

	for(int s=1;s<=CountSurfaces();s++){
	
		Surface* surf=GetSurface(s);
			
		for(int v=0;v<=surf->CountVertices()-1;v++){
	
			float vx=surf->vert_coords[v*3];
			float vy=surf->vert_coords[v*3+1];
			float vz=surf->vert_coords[v*3+2];

			surf->vert_coords[v*3] = mat.grid[0][0]*vx + mat.grid[1][0]*vy + mat.grid[2][0]*vz + mat.grid[3][0];
			surf->vert_coords[v*3+1] = mat.grid[0][1]*vx + mat.grid[1][1]*vy + mat.grid[2][1]*vz + mat.grid[3][1];
			surf->vert_coords[v*3+2] = mat.grid[0][2]*vx + mat.grid[1][2]*vy + mat.grid[2][2]*vz + mat.grid[3][2];

			float nx=surf->vert_norm[v*3];
			float ny=surf->vert_norm[v*3+1];
			float nz=surf->vert_norm[v*3+2];

			surf->vert_norm[v*3] = mat.grid[0][0]*nx + mat.grid[1][0]*ny + mat.grid[2][0]*nz + mat.grid[3][0];
			surf->vert_norm[v*3+1] = mat.grid[0][1]*nx + mat.grid[1][1]*ny + mat.grid[2][1]*nz + mat.grid[3][1];
			surf->vert_norm[v*3+2] = mat.grid[0][2]*nx + mat.grid[1][2]*ny + mat.grid[2][2]*nz + mat.grid[3][2];

		}
		
		// mesh shape has changed - update reset flag
		surf->reset_vbo=surf->reset_vbo|1|4;
						
	}
	
	// mesh shape has changed - update reset flag
	reset_bounds=true;
	reset_col_tree=true;
			
}
	
void Mesh::PositionMesh(float px,float py,float pz){

	pz=-pz;

	for(int s=1;s<=CountSurfaces();s++){
	
		Surface* surf=GetSurface(s);
			
		for(int v=0;v<=surf->CountVertices()-1;v++){
	
			surf->vert_coords[v*3]+=px;
			surf->vert_coords[v*3+1]+=py;
			surf->vert_coords[v*3+2]+=pz;

		}
		
		// mesh shape has changed - update reset flag
		surf->reset_vbo=surf->reset_vbo|1;
					
	}
	
	// mesh shape has changed - update reset flags
	reset_bounds=true;
	reset_col_tree=true;
	
}

void Mesh::UpdateNormals(){

	list<Surface*>::iterator it;
	
	for(it=surf_list.begin();it!=surf_list.end();it++){
	
		Surface& surf=**it;
	
		surf.UpdateNormals();
	
	}
	
}

float Mesh::MeshWidth(){

	GetBounds();

	return max_x-min_x;
	
}

float Mesh::MeshHeight(){

	GetBounds();

	return max_y-min_y;
	
}

float Mesh::MeshDepth(){

	GetBounds();

	return max_z-min_z;
	
}

int Mesh::CountSurfaces(){

	return no_surfs;

}
	
Surface* Mesh::GetSurface(int surf_no_get){
	
	int surf_no=0;
	
	list<Surface*>::iterator it;
	
	for(it=surf_list.begin();it!=surf_list.end();it++){
	
		Surface* surf=*it;
		
		surf_no=surf_no+1;
			
		if(surf_no_get==surf_no) return surf;
	
	}
	
	return NULL;
	
}

/*	
	Method FindSurface:TSurface(brush:TBrush)
	
		' ***note*** unlike B3D version, this will find a surface with no brush, if a null brush is supplied
	
		For Local surf:TSurface=EachIn surf_list
		
			If TBrush.CompareBrushes(brush,surf.brush)=True
				Return surf
			EndIf
		
		Next
		
		Return Null
	
	End Method
		
	' returns total no. of vertices in mesh
	Method CountVertices()
	
		Local verts=0
	
		For Local s=1 To CountSurfaces()
		
			Local surf:TSurface=GetSurface(s)	
		
			verts=verts+surf.CountVertices()
		
		Next
	
		Return verts
	
	End Method
	
	' returns total no. of triangles in mesh
	Method CountTriangles()
	
		Local tris=0
	
		For Local s=1 To CountSurfaces()
		
			Local surf:TSurface=GetSurface(s)	
		
			tris=tris+surf.CountTriangles()
		
		Next
	
		Return tris
	
	End Method

*/
		
// used by CopyEntity
void Mesh::CopyBonesList(Entity* ent,vector<Bone*>& bones){

	list<Entity*>::iterator it;
	for(it=ent->child_list.begin();it!=ent->child_list.end();it++){
		
		Entity* child_ent=*it;
		
		if(dynamic_cast<Bone*>(child_ent)){
			bones.push_back(dynamic_cast<Bone*>(child_ent));
		}
		CopyBonesList(child_ent,bones);
		
	}
	
	return;

}

//used by LoadMesh
Mesh* Mesh::CollapseAnimMesh(Mesh* mesh){

	if(mesh==NULL) mesh=new Mesh();
	
	if(dynamic_cast<Mesh*>(this)){
		TransformMesh(mat);
		AddMesh(mesh);
	}
	
	mesh=CollapseChildren(this,mesh);

	return mesh;

}

// used by LoadMesh
// has to be function as we need to use this function with all entities and not just meshes
Mesh* Mesh::CollapseChildren(Entity* ent0,Mesh* mesh){

	for(int i=1;i<=ent0->CountChildren();i++){
		Entity* ent=ent0->GetChild(i);
		if(dynamic_cast<Mesh*>(ent)){
			dynamic_cast<Mesh*>(ent)->TransformMesh(ent->mat);
			dynamic_cast<Mesh*>(ent)->AddMesh(mesh);
		}
		mesh=CollapseChildren(ent,mesh);
	}
	
	return mesh;
	
}

// used by LoadMesh
void Mesh::TransformMesh(Matrix& mat){

	for(int s=1;s<=no_surfs;s++){

		Surface& surf=*GetSurface(s);
			
		for(int v=0;v<=surf.no_verts-1;v++){
	
			float vx=surf.vert_coords[v*3];
			float vy=surf.vert_coords[v*3+1];
			float vz=surf.vert_coords[v*3+2];

			surf.vert_coords[v*3] = mat.grid[0][0]*vx + mat.grid[1][0]*vy + mat.grid[2][0]*vz + mat.grid[3][0];
			surf.vert_coords[v*3+1] = mat.grid[0][1]*vx + mat.grid[1][1]*vy + mat.grid[2][1]*vz + mat.grid[3][1];
			surf.vert_coords[v*3+2] = mat.grid[0][2]*vx + mat.grid[1][2]*vy + mat.grid[2][2]*vz + mat.grid[3][2];

			float nx=surf.vert_norm[v*3];
			float ny=surf.vert_norm[v*3+1];
			float nz=surf.vert_norm[v*3+2];

			surf.vert_norm[v*3] = mat.grid[0][0]*nx + mat.grid[1][0]*ny + mat.grid[2][0]*nz;
			surf.vert_norm[v*3+1] = mat.grid[0][1]*nx + mat.grid[1][1]*ny + mat.grid[2][1]*nz;
			surf.vert_norm[v*3+2] = mat.grid[0][2]*nx + mat.grid[1][2]*ny + mat.grid[2][2]*nz;

		}
						
	}

}

// used by MeshWidth, MeshHeight, MeshDepth, RenderWorld
void Mesh::GetBounds(){

	// only get new bounds if we have to
	// mesh.reset_bounds=True for all new meshes, plus set to True by various Mesh commands
	if(reset_bounds==true){
	
		reset_bounds=false;

		min_x=999999999;
		max_x=-999999999;
		min_y=999999999;
		max_y=-999999999;
		min_z=999999999;
		max_z=-999999999;
		
		for(int s=1;s<=CountSurfaces();s++){
		
			Surface* surf=GetSurface(s);
	
			for(int v=0;v<=surf->CountVertices()-1;v++){
			
				float x=surf->vert_coords[v*3]; // surf.VertexX(v)
				if(x<min_x) min_x=x;
				if(x>max_x) max_x=x;
				
				float y=surf->vert_coords[(v*3)+1]; // surf.VertexY(v)
				if(y<min_y) min_y=y;
				if(y>max_y) max_y=y;
				
				float z=-surf->vert_coords[(v*3)+2]; // surf.VertexZ(v)
				if(z<min_z) min_z=z;
				if(z>max_z) max_z=z;
			
			}
		
		}
	
		// get mesh width, height, depth
		float width=max_x-min_x;
		float height=max_y-min_y;
		float depth=max_z-min_z;
		
		// get bounding sphere (cull_radius) from AABB
		// only get cull radius (auto cull), if cull radius hasn't been set to a negative no. by TEntity.MeshCullRadius (manual cull)
		if(cull_radius>=0){
			if(width>=height && width>=depth){
				cull_radius=width;
			}else{
				if(height>=width && height>=depth){
					cull_radius=height;
				}else{
					cull_radius=depth;
				}
			}
			cull_radius=cull_radius/2.0;
			float crs=cull_radius*cull_radius;
			cull_radius=sqrt(crs+crs+crs);
		}

	}

}

// returns true if mesh is to be drawn with alpha, i.e alpha<1.0.
// this func is used in MeshListAdd to see whether entity should be manually depth sorted (if alpha=true then yes).
// alpha_enable true/false is also set for surfaces - this is used to sort alpha surfaces and enable/disable alpha blending 
// in TMesh.Update.
int Mesh::Alpha(){

	// ***note*** func doesn't taken into account fact that surf brush blend modes override master brush blend mode
	// when rendering. shouldn't be a problem, as will only incorrectly return true if master brush blend is 2 or 3,
	// while surf blend is 1. won't crop up often, and if it does, will only result in blending being enabled when it
	// shouldn't (may cause interference if surf tex is masked?).

	int alpha=false;

	// check master brush (check alpha value, blend value, force vertex alpha flag)
	if(brush.alpha<1.0 || brush.blend==2 || brush.blend==3 || brush.fx&32){
		
		alpha=true;

	}else{
	
		// tex 0 alpha flag
		if(brush.tex[0]){
			if(brush.tex[0]->flags&2){
				alpha=true;
			}
		}
		
	}

	// check surf brushes
	list<Surface*>::iterator it;
	
	for(it=surf_list.begin();it!=surf_list.end();it++){
	
		Surface& surf=**it;
	
		surf.alpha_enable=false;
		
		//if(surf.brush){
		
			if(surf.brush->alpha<1.0 || surf.brush->blend==2 || surf.brush->blend==3 || surf.brush->fx&32){
			
				alpha=true;
	
			}else{
			
				if(surf.brush->tex[0]){
					if(surf.brush->tex[0]->flags&2){
						alpha=true;
					}
				}
				
			}
		
		//}
		
		// entity auto fade
		if(fade_alpha!=0.0){
			alpha=true;
		}		
		// set surf alpha_enable flag to true if mesh or surface has alpha properties
		if(alpha==true){
			surf.alpha_enable=true;
		}
		
	}

	return alpha;

}

void Mesh::TreeCheck(){

	// if reset_col_tree flag is true clear tree
	if(reset_col_tree==true){

		if(c_col_tree!=NULL){
			C_DeleteColTree(c_col_tree);
			c_col_tree=NULL;
		}
		reset_col_tree=0;
			
	}

	if(c_col_tree==NULL){

		int total_verts=0;
		MeshInfo* mesh_info=C_NewMeshInfo();

		for(int s=1;s<=CountSurfaces();s++){
			
			Surface* surf=GetSurface(s);
				
			int no_tris=surf->no_tris;
			int no_verts=surf->no_verts;
			
			// copy arrays
			//Local tris:Short[]=surf.tris[..]
			//Local verts:Float[]=surf.vert_coords[..]

			// copy arrays
			short* tris=new short[no_tris*3];
			float* verts=new float[no_verts*3];
			for(int i=0;i<no_tris*3;i++){
				tris[i]=surf->tris[i];
			}
			for(int i=0;i<no_verts*3;i++){
				verts[i]=surf->vert_coords[i];
			}

			if(no_tris!=0 && no_verts!=0){
				
				// inc vert index
				for(int i=0;i<=no_tris-1;i++){
					tris[i*3+0]+=total_verts;
					tris[i*3+1]+=total_verts;
					tris[i*3+2]+=total_verts;
				}
				
				// reverse vert order
				for(int i=0;i<=no_tris-1;i++){
					int t_v0=tris[i*3+0];
					int t_v2=tris[i*3+2];
					tris[i*3+0]=t_v2;
					tris[i*3+2]=t_v0;
				}
				
				// negate z vert coords
				for(int i=0;i<=no_verts-1;i++){
					verts[i*3+2]=-verts[i*3+2];
				}

				C_AddSurface(mesh_info,no_tris,no_verts,tris,verts,s);
				
				total_verts+=no_verts;
								
			}

			delete [] tris;
			delete [] verts;
			
		}
		
		c_col_tree=C_CreateColTree(mesh_info);
		C_DeleteMeshInfo(mesh_info);
		
	}
	
}

void Mesh::Render(){

	// depth mask and fog are enabled at start of func. may be disabled during func. if so, enable again at end of func
	int depth_mask_disabled=false;
	//int fog_disabled=false;
	
	glDisable(GL_ALPHA_TEST); // ?
	
	if(order!=0){
		glDisable(GL_DEPTH_TEST); // o
		glDepthMask(GL_FALSE);
		depth_mask_disabled=true;
	}else{
		glEnable(GL_DEPTH_TEST); // o
		//glDepthMask(GL_TRUE); already set to true
	}
	
	// ***todo*** surface sorting
	// sort by alpha true/false (we need to draw surfaces with alpha last)

	list<Surface*>::iterator anim_surf_it;
	anim_surf_it=anim_surf_list.begin();
	Surface& anim_surf=**anim_surf_it;
	
	list<Surface*>::iterator surf_it;
	
	int any_surf=false;
	
	for(surf_it=surf_list.begin();surf_it!=surf_list.end();surf_it++){
	
		any_surf=true;
	
		Surface& surf=**surf_it;

		int vbo=false;
		if(surf.vbo_enabled==true && surf.no_tris>=Global::vbo_min_tris){
			vbo=true;
		}else{
			// if surf no longer has required no of tris then free vbo
			if(surf.vbo_id[0]!=0){ 
				glDeleteBuffers(6,surf.vbo_id);
			}
		}

		// update surf vbo if necessary
		if(vbo==true){
			
			// update vbo
			if(surf.reset_vbo!=false){
				surf.UpdateVBO();
			}else if(surf.vbo_id[0]==0){ // no vbo - unknown reason
				surf.reset_vbo=-1;
				surf.UpdateVBO();
			}
			
		}

		if(anim==true){
		
			// get anim_surf
			
			Surface& anim_surf=**anim_surf_it;
			anim_surf_it++;

			if(vbo==true){
			
				// update vbo
				if(anim_surf.reset_vbo!=false){
					anim_surf.UpdateVBO();
				}else if(anim_surf.vbo_id[0]==0){ // no vbo - unknown reason
					anim_surf.reset_vbo=-1;
					anim_surf.UpdateVBO();
				}
			
			}
			
		}

		float red,green,blue,alpha,shine;
		int blend,fx;
		float ambient_red,ambient_green,ambient_blue;

		// get main brush values
		red  =brush.red;
		green=brush.green;
		blue =brush.blue;
		alpha=brush.alpha;
		shine=brush.shine;
		blend =brush.blend;
		fx    =brush.fx;
		
		// combine surface brush values with main brush values
		//if(surf.brush!=NULL){

			float shine2=0.0;

			red   =red  *surf.brush->red;
			green =green*surf.brush->green;
			blue  =blue *surf.brush->blue;
			alpha =alpha*surf.brush->alpha;
			shine2=surf.brush->shine;
			if(shine==0.0) shine=shine2;
			if(shine!=0.0 && shine2!=0.0) shine=shine*shine2;
			if(blend==0) blend=surf.brush->blend; // overwrite master brush if master brush blend=0
			fx=fx|surf.brush->fx;
		
		//}

		// take into account auto fade alpha
		alpha=alpha-fade_alpha;
		
		static int alpha_enable=-1;
		if(surf.alpha_enable==true){
			if(alpha_enable!=true){
				alpha_enable=true;
				glEnable(GL_BLEND);
			}
			glDepthMask(GL_FALSE); // must be set to false every time, as it's always equal to true before it's called
			depth_mask_disabled=true; // set this to true to we know when to enable depth mask at bottom of function
		}else{
			if(alpha_enable!=false){
				alpha_enable=false;
				glDisable(GL_BLEND);
				//glDepthMask(GL_TRUE); already set to true
			}
		}
			
		// blend modes
		
		static int blend_mode=-1;
		if(blend!=blend_mode){
			blend_mode=blend;
		
			switch(blend){
				case 0:
					glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); // alpha
					break;
				case 1:
					glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); // alpha
					break;
				case 2:
					glBlendFunc(GL_DST_COLOR,GL_ZERO); // multiply
					break;
				case 3:
					glBlendFunc(GL_SRC_ALPHA,GL_ONE); // additive and alpha
					break;
                case 4:
                    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA); // pre-multiplied alpha
                    break;
                default:
                    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                    break;
			}
		
		}
		
		// fx modes
		
		// fx flag 1 - full bright ***todo*** disable all lights?
		static int fx1=-1;
		if(fx&1){
			if(fx1!=true){
				fx1=true;
				glDisableClientState(GL_NORMAL_ARRAY);
			}
			ambient_red  =1.0;
			ambient_green=1.0;
			ambient_blue =1.0;
		}else{
			if(fx1!=false){
				fx1=false;
				glEnableClientState(GL_NORMAL_ARRAY);
			}
			ambient_red  =Global::ambient_red;
			ambient_green=Global::ambient_green;
			ambient_blue =Global::ambient_blue;
		}

		// fx flag 2 - vertex colours
		static int fx2=-1;
		if(fx&2){
			if(fx2!=true){
				fx2=true;
				glEnableClientState(GL_COLOR_ARRAY);
				glEnable(GL_COLOR_MATERIAL);
			}
		}else{
			if(fx2!=false){
				fx2=false;
				glDisableClientState(GL_COLOR_ARRAY);
				glDisable(GL_COLOR_MATERIAL);
			}
		}
		
		// fx flag 4 - flatshaded
		static int fx4=-1;
		if(fx&4){
			if(fx4!=true){
				fx4=true;
				glShadeModel(GL_FLAT);
			}
		}else{
			if(fx4!=false){
				fx4=false;
				glShadeModel(GL_SMOOTH);
			}
		}

		// fx flag 8 - disable fog
		if(fx&8){
			//if(Global::fog_enabled==true){ // only disable if fog enabled in camera update
			glDisable(GL_FOG);
			//	fog_disabled=true;
			//}
		}
		
		// fx flag 16 - disable backface culling
		static int fx16=-1;
		if(fx&16){
			if(fx16!=true){
				fx16=true;
				glDisable(GL_CULL_FACE);
			}
		}else{
			if(fx16!=false){
				fx16=false;
				glEnable(GL_CULL_FACE);
			}
		}

		// vertex data
		if(vbo){
		
			if(anim_render){
				glBindBuffer(GL_ARRAY_BUFFER,anim_surf.vbo_id[0]);
				glVertexPointer(3,GL_FLOAT,0,NULL);
			}else{
				glBindBuffer(GL_ARRAY_BUFFER,surf.vbo_id[0]);
				glVertexPointer(3,GL_FLOAT,0,NULL);
			}
						
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,surf.vbo_id[5]);
				
			if(fx&1){ // if full-bright flag, don't use normal data
			}else{
				glBindBuffer(GL_ARRAY_BUFFER,surf.vbo_id[3]);
				glNormalPointer(GL_FLOAT,0,NULL);
			}
			
			if(fx&2){ // if vertex colours flag - use colour data
				glBindBuffer(GL_ARRAY_BUFFER,surf.vbo_id[4]);
				glColorPointer(4,GL_FLOAT,0,NULL);
			}
			
		}else{
	
			glBindBuffer(GL_ARRAY_BUFFER,0); // reset - necessary for when non-vbo surf follows vbo surf
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
	
			if(anim_render){
				glVertexPointer(3,GL_FLOAT,0,&anim_surf.vert_coords[0]);
			}else{
				glVertexPointer(3,GL_FLOAT,0,&surf.vert_coords[0]);
			}
			
			if(fx&1){ // if full-bright flag, don't use normal data
				glNormalPointer(GL_FLOAT,0,NULL);
			}else{
				glNormalPointer(GL_FLOAT,0,&surf.vert_norm[0]);
			}
		
			if(fx&2){ // if vertex colours flag - use colour data
				glColorPointer(4,GL_FLOAT,0,&surf.vert_col[0]);
			}else{
				glColorPointer(4,GL_FLOAT,0,NULL);
			}
			
		}
						
		// light + material color
		
		float ambient[]={ambient_red,ambient_green,ambient_blue};	
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT,ambient);
		
		//float no_mat[]={0.0,0.0};
		float mat_ambient[]={red,green,blue,alpha};
		float mat_diffuse[]={red,green,blue,alpha};
		float mat_specular[]={shine,shine,shine,shine};
		float mat_shininess[]={100.0}; // upto 128

		glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,mat_ambient);
		glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,mat_diffuse);
		glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,mat_specular);
		glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS,mat_shininess);

		// textures
			
		int tex_count=0;
		tex_count=brush.no_texs;
		//if(surf.brush!=NULL){
			if(surf.brush->no_texs>tex_count) tex_count=surf.brush->no_texs;
		//}

		for(int ix=0;ix<tex_count;ix++){

			if(surf.brush->tex[ix] || brush.tex[ix]){
				
				// Main brush texture takes precedent over surface brush texture
				Texture* texture=NULL;
				int tex_flags=0,tex_blend=0,tex_coords=0;
				float tex_u_scale=1.0,tex_v_scale=1.0,tex_u_pos=0.0,tex_v_pos=0.0,tex_ang=0.0;
				//int tex_cube_mode=0,frame=0;

				if(brush.tex[ix]){
					texture=brush.tex[ix];
					tex_flags=brush.tex[ix]->flags;
					tex_blend=brush.tex[ix]->blend;
					tex_coords=brush.tex[ix]->coords;
					tex_u_scale=brush.tex[ix]->u_scale;
					tex_v_scale=brush.tex[ix]->v_scale;
					tex_u_pos=brush.tex[ix]->u_pos;
					tex_v_pos=brush.tex[ix]->v_pos;
					tex_ang=brush.tex[ix]->angle;
					//tex_cube_mode=brush.tex[ix]->cube_mode;
					//frame=brush.tex_frame;
				}else{
					texture=surf.brush->tex[ix];
					tex_flags=surf.brush->tex[ix]->flags;
					tex_blend=surf.brush->tex[ix]->blend;
					tex_coords=surf.brush->tex[ix]->coords;
					tex_u_scale=surf.brush->tex[ix]->u_scale;
					tex_v_scale=surf.brush->tex[ix]->v_scale;
					tex_u_pos=surf.brush->tex[ix]->u_pos;
					tex_v_pos=surf.brush->tex[ix]->v_pos;
					tex_ang=surf.brush->tex[ix]->angle;
					//tex_cube_mode=surf.brush.tex[ix]->cube_mode;
					//frame=surf.brush.tex_frame;
				}

				glActiveTexture(GL_TEXTURE0+ix);
				glClientActiveTexture(GL_TEXTURE0+ix);

				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D,texture->texture.name); // call before glTexParameteri

				// masked texture flag
				if(tex_flags&4){
					glEnable(GL_ALPHA_TEST);
				}else{
					glDisable(GL_ALPHA_TEST);
				}
			
				// mipmapping texture flag
				if(tex_flags&8){
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
				}else{
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
				}
				
				// clamp u flag
				if(tex_flags&16){
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
				}else{						
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
				}
				
				// clamp v flag
				if(tex_flags&32){
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
				}else{
					glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
				}
	
				// ***!ES***
				/*
				// spherical environment map texture flag
				if(tex_flags&64!=0){
					glTexGeni(GL_S,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP);
					glTexGeni(GL_T,GL_TEXTURE_GEN_MODE,GL_SPHERE_MAP);
					glEnable(GL_TEXTURE_GEN_S);
					glEnable(GL_TEXTURE_GEN_T);
				}else{
					glDisable(GL_TEXTURE_GEN_S);
					glDisable(GL_TEXTURE_GEN_T);
				}
			
				// cubic environment map texture flag
				if(tex_flags&128!=0){
	
					glEnable(GL_TEXTURE_CUBE_MAP);
					glBindTexture(GL_TEXTURE_CUBE_MAP,texture->texture.name); // call before glTexParameteri
					
					glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
					glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
					glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
					glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
					glTexParameteri(GL_TEXTURE_CUBE_MAP,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
					
					glEnable(GL_TEXTURE_GEN_S);
					glEnable(GL_TEXTURE_GEN_T);
					glEnable(GL_TEXTURE_GEN_R);
					//glEnable(GL_TEXTURE_GEN_Q)

					if(tex_cube_mode==1){
						glTexGeni(GL_S,GL_TEXTURE_GEN_MODE,GL_REFLECTION_MAP);
						glTexGeni(GL_T,GL_TEXTURE_GEN_MODE,GL_REFLECTION_MAP);
						glTexGeni(GL_R,GL_TEXTURE_GEN_MODE,GL_REFLECTION_MAP);
					}
					
					if(tex_cube_mode==2){
						glTexGeni(GL_S,GL_TEXTURE_GEN_MODE,GL_NORMAL_MAP);
						glTexGeni(GL_T,GL_TEXTURE_GEN_MODE,GL_NORMAL_MAP);
						glTexGeni(GL_R,GL_TEXTURE_GEN_MODE,GL_NORMAL_MAP);
					}
		
				}else{

					glDisable(GL_TEXTURE_CUBE_MAP);
					
					// only disable tex gen s and t if sphere mapping isn't using them
					if(tex_flags&64==0){
						glDisable(GL_TEXTURE_GEN_S);
						glDisable(GL_TEXTURE_GEN_T);
					}
					
					glDisable(GL_TEXTURE_GEN_R);
					//glDisable(GL_TEXTURE_GEN_Q)
	
				}
				*/
				
				switch(tex_blend){
					case 0: glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_REPLACE);
					break;
					case 1: glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_REPLACE);
					break;
					case 2: glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
					//case 2 glTexEnvf(GL_TEXTURE_ENV,GL_COMBINE_RGB_EXT,GL_MODULATE);
					break;
					case 3: glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_ADD);
					break;
					case 4:
						//glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE_EXT); ***!ES***
						//glTexEnvf(GL_TEXTURE_ENV, GL_COMBINE_RGB_EXT, GL_DOT3_RGB_EXT); ***!ES***
						break;
					case 5:
						glTexEnvi(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_COMBINE);
						glTexEnvi(GL_TEXTURE_ENV,GL_COMBINE_RGB,GL_MODULATE);
						glTexEnvi(GL_TEXTURE_ENV,GL_RGB_SCALE,2.0);
						break;
					default: glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
				}

				glEnableClientState(GL_TEXTURE_COORD_ARRAY);

				if(vbo){
				
					if(tex_coords==0){
						glBindBuffer(GL_ARRAY_BUFFER,surf.vbo_id[1]);
						glTexCoordPointer(2,GL_FLOAT,0,NULL);
					}else{
						glBindBuffer(GL_ARRAY_BUFFER,surf.vbo_id[2]);
						glTexCoordPointer(2,GL_FLOAT,0,NULL);
					}
					
				}else{
				
					if(tex_coords==0){
						//glBindBufferARB(GL_ARRAY_BUFFER_ARB,0) already reset above
						glTexCoordPointer(2,GL_FLOAT,0,&surf.vert_tex_coords0[0]);
					}else{
						//glBindBufferARB(GL_ARRAY_BUFFER_ARB,0)
						glTexCoordPointer(2,GL_FLOAT,0,&surf.vert_tex_coords1[0]);
					}

				}
						
				// reset texture matrix
				glMatrixMode(GL_TEXTURE);
				glLoadIdentity();
						
				if(tex_u_pos!=0.0 || tex_v_pos!=0.0){
					glTranslatef(tex_u_pos,tex_v_pos,0.0);
				}
				if(tex_ang!=0.0){
					glRotatef(tex_ang,0.0,0.0,1.0);
				}
				if(tex_u_scale!=1.0 || tex_v_scale!=1.0){
					glScalef(tex_u_scale,tex_v_scale,1.0);
				}
	
				/* ***!ES***
				// if spheremap flag=true then flip tex
				if(tex_flags&64!=0){
					glScalef(1.0,-1.0,-1.0);
				}
				
				// if cubemap flag=true then manipulate texture matrix so that cubemap is displayed properly 
				if(tex_flags&128!=0){

					glScalef(1.0,-1.0,-1.0);
					
					// get current modelview matrix (set in last camera update)
					float mod_mat[16];
					glGetFloatv(GL_MODELVIEW_MATRIX,&mod_mat[0]);

					// get rotational inverse of current modelview matrix
					Matrix new_mat;
					new_mat.LoadIdentity();
					
					new_mat.grid[0][0] = mod_mat[0];
					new_mat.grid[1][0] = mod_mat[1];
					new_mat.grid[2][0] = mod_mat[2];

					new_mat.grid[0][1] = mod_mat[4];
					new_mat.grid[1][1] = mod_mat[5];
					new_mat.grid[2][1] = mod_mat[6];

					new_mat.grid[0][2] = mod_mat[8];
					new_mat.grid[1][2] = mod_mat[9];
					new_mat.grid[2][2] = mod_mat[10];
					
					glMultMatrixf(&new_mat.grid[0][0]);

				}
				*/
								
			}
		
		}
			
		// draw tris
		
		glMatrixMode(GL_MODELVIEW);

		glPushMatrix();

		if(dynamic_cast<Sprite*>(this)==NULL){
			glMultMatrixf(&mat.grid[0][0]);
		}else{
			glMultMatrixf(&mat_sp.grid[0][0]);
		}
		
		if(vbo){																																																																																																																																																																																																																																																																																
			glDrawElements(GL_TRIANGLES,surf.no_tris*3,GL_UNSIGNED_SHORT,NULL);
		}else{
			glDrawElements(GL_TRIANGLES,surf.no_tris*3,GL_UNSIGNED_SHORT,&surf.tris[0]);
		}

		glPopMatrix();
		
		// disable all texture layers
		for(int ix=0;ix<tex_count;ix++){
	
			glActiveTexture(GL_TEXTURE0+ix);
			glClientActiveTexture(GL_TEXTURE0+ix);
			
			// reset texture matrix
			glMatrixMode(GL_TEXTURE);
			glLoadIdentity();
			
			glDisable(GL_TEXTURE_2D);
			
			// ***!ES***
			//glDisable(GL_TEXTURE_CUBE_MAP);
			//glDisable(GL_TEXTURE_GEN_S);
			//glDisable(GL_TEXTURE_GEN_T);
			//glDisable(GL_TEXTURE_GEN_R);
		
		}
				
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);

		// enable depth mask again if it was disabled when blend was enabled
		if(depth_mask_disabled==true){
			glDepthMask(GL_TRUE);
			depth_mask_disabled=false; // set to false again for when we repeat loop
		}

		// enable fog again if fog was already enabled in camera update, and disabled above
		//if(Camera::fog_enabled==true && fog_disabled==true){
			//glEnable(GL_FOG);
			//fog_disabled=false; // set to false again for when we repeat loop
		//}
		
	}
	
	// repeat these here in case no surfaces?
	
	// enable depth mask again if it was disabled when blend was enabled
	if(depth_mask_disabled==true){
		glDepthMask(GL_TRUE);
		depth_mask_disabled=false; // set to false again for when we repeat loop
	}

	// enable fog again if fog was already enabled in camera update, and disabled above
	//if(Global::fog_enabled==true && fog_disabled==true){
		//glEnable(GL_FOG);
		//fog_disabled=false; // set to false again for when we repeat loop
	//}

	// enable fog again if fog was already enabled in camera update
	if(Global::fog_enabled==true){
		glEnable(GL_FOG);
	}
	
	if(any_surf==false) cout << "No surf: " << EntityName() << endl;

}