using UnityEngine;
using UnityEngine.SceneManagement;

using UnityEditor;
using System.Collections;

class LoliToolMain : EditorWindow {
    [MenuItem ("Loli Tool/Window")]

    public static void  ShowWindow () {
        EditorWindow.GetWindow(typeof(LoliToolMain));
    }
    
    bool click;
    public Object sourceScene;

    void OnGUI () {

		Scene scene = SceneManager.GetActiveScene();
		GameObject[] gameObjects = SceneManager.GetSceneByName(scene.name).GetRootGameObjects();

    	EditorGUILayout.LabelField ("Scene analyzer");
    	EditorGUILayout.HelpBox ("Active Scene: " + scene.name, MessageType.Info);

    	if (GUILayout.Button ("Analysis Scene")) click = !click;
    	if (click == true) {


	        /*foreach (GameObject go in Resources.FindObjectsOfTypeAll(typeof(GameObject)) as GameObject[])  {

		            if (go.GetComponent<MeshFilter>() != null) {
			            if (go.GetComponent<MeshFilter>().sharedMesh != null) {
			            	if (go.GetComponent<MeshFilter>().name == "trashcan_big (6)") {
				            	Debug.Log(go.GetComponent<MeshFilter>().name);
				            	Unwrapping.GenerateSecondaryUVSet (go.GetComponent<MeshFilter>().sharedMesh);
				            }
			            }
		            }

	        }

	        /*
	        for(int i = 0; i < meshes.Length; i++) {

	        	GameObject mesh = Instantiate(meshes[i]) as GameObject;

	        	if (mesh != null) {
	        		if (mesh.GetComponent<MeshFilter>() != null) {
						Debug.Log(mesh.GetComponent<MeshFilter>().mesh);
	        		} else Debug.Log(mesh.name + " not meshFilter");
	        	}
	            

	            //Unwrapping.GenerateSecondaryUVSet (meshes[i]);
	        }
	        */

		    

    	}

    }

}