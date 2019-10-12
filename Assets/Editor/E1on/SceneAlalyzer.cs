using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using VRCSDK2;
using VRCSDK2.scripts.Scenes;

// Reconstruction
//namespace E1on.HardCode
namespace E1on
{
    class SceneAnalyzer : EditorWindow
    {

        private GameObject[] SceneObjects;
        
        [MenuItem("Loli E1ON/Analyzer Reconstruction test123")]
        public static void ShowWindow()
        {
            EditorWindow.GetWindow(typeof(SceneAnalyzer));
        }

        public void OnGUI()
        {
            this.SceneObjects = Resources.FindObjectsOfTypeAll(typeof(GameObject)) as GameObject[];
            foreach (GameObject gameObject in this.SceneObjects)
            {
                if (gameObject.GetComponent<VRC_Panorama>() != null)
                {
                    Debug.Log(gameObject.name);
                }
            }
        }
    }
}