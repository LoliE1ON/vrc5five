using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using System.Collections;
using VRCSDK2;

namespace E1on
{
    class Analyzer : EditorWindow
    {
        bool analyzeScene = false;
        bool showInfo = false;

        private static bool audioToggle = true;

        GameObject[] gameObjects;
        
        int totalMeshes, totalSkinnedMeshes, totalPolygons = 0;
        int totalAudios, totalAnimators = 0;
        int totalPickups, totalChairs = 0;

        static GUIStyle boxGuiStyle;

        [MenuItem ("Loli E1ON/Analyzer")]
        public static void ShowWindow ()
        {
            EditorWindow.GetWindow(typeof(Analyzer));
        }

        public void OnGUI()
        {
            Scene scene = SceneManager.GetActiveScene();
            this.gameObjects = Resources.FindObjectsOfTypeAll(typeof(GameObject)) as GameObject[];

            boxGuiStyle = new GUIStyle();
            boxGuiStyle.normal.background = Texture2D.whiteTexture;
            boxGuiStyle.normal.textColor = new Color(0.85f, 0.85f, 0.85f);

            EditorGUILayout.Space();
            EditorGUILayout.HelpBox ("Current Scene: " + scene.name, MessageType.Info);
            if (GUILayout.Button ("Analysis Scene")) analyzeScene = !analyzeScene;
            EditorGUILayout.Space();

            if (showInfo) {


                EditorGUILayout.BeginVertical(boxGuiStyle);
                EditorGUILayout.LabelField("VRChat", EditorStyles.boldLabel);
                EditorGUILayout.EndVertical();

                EditorGUILayout.HelpBox ("Pickups: " + this.totalPickups, MessageType.Info);
                EditorGUILayout.HelpBox ("Chairs: " + this.totalChairs, MessageType.Info);

                EditorGUILayout.BeginVertical(boxGuiStyle);
                EditorGUILayout.LabelField("Enviroument", EditorStyles.boldLabel);
                EditorGUILayout.EndVertical();

                EditorGUILayout.HelpBox ("Polygons: " + this.totalPolygons, MessageType.Info);
                EditorGUILayout.HelpBox ("Meshes: " + this.totalMeshes, MessageType.Info);
                EditorGUILayout.HelpBox ("Skinned Meshes: " + this.totalSkinnedMeshes, MessageType.Info);

                EditorGUILayout.HelpBox ("Audio: " + this.totalAudios, MessageType.Info);
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Audio", EditorStyles.boldLabel, GUILayout.ExpandWidth(false), GUILayout.Width(58));
                audioToggle = EditorGUILayout.Foldout(audioToggle, new GUIContent(""));
                EditorGUILayout.EndHorizontal();

                if (audioToggle) {
                     EditorGUILayout.LabelField("test", EditorStyles.boldLabel, GUILayout.ExpandWidth(false), GUILayout.Width(58));
                }
                
                EditorGUILayout.HelpBox ("Animators: " + this.totalAnimators, MessageType.Info);




            }

            if (analyzeScene) {
                this.ResetCounters();
                this.Analyze();
                this.RenderInfo();
                analyzeScene = !analyzeScene;
            }
        }

        private void Analyze()
        {
            foreach (GameObject go in this.gameObjects)  {

                if (go.GetComponent<MeshFilter>() != null) {
                    this.totalMeshes++;
                    if (go.GetComponent<MeshFilter>().sharedMesh != null) {
                        this.totalPolygons = this.totalPolygons + go.GetComponent<MeshFilter>().sharedMesh.vertexCount;
                    }
                }

                if (go.GetComponent<AudioSource>() != null) {
                    this.totalAudios++;
                }

                if (go.GetComponent<Animator>() != null) {
                    this.totalAnimators++;
                }

                if (go.GetComponent<VRC_Pickup>() != null) {
                    this.totalPickups++;
                }
                if (go.GetComponent<VRC_Station>() != null) {
                    this.totalChairs++;
                }
                if (go.GetComponent<SkinnedMeshRenderer>() != null) {
                    this.totalSkinnedMeshes++;
                }
            }
        }

        private void ResetCounters() {
            this.totalMeshes = 0;
            this.totalAudios = 0;
            this.totalAnimators = 0;
            this.totalPickups = 0;
            this.totalPolygons = 0;
            this.totalChairs = 0;
            this.totalSkinnedMeshes = 0;
        }

        private void RenderInfo() {
            this.showInfo = true;
        }

    }

}