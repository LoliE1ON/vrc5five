using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using VRCSDK2;

// Reconstruction
//namespace E1on.HardCode
namespace E1on
{
    class AnalyzerReconstruction : EditorWindow
    {   
        // Позиция скрола
        private Vector2 ScrollPosition;

        // Статусы
        private bool AnalyzeScene = false;
        private bool ShowInfo = false;

        // Стили для тайтлов
        private GUIStyle boxGuiStyle;

        // Список всех обьектов на сцене
        private GameObject[] SceneObjects;

        // Список отслеживаемых компонентов
        private Dictionary<string, string> Components = new Dictionary<string, string>();
        private Dictionary<string, List<GameObject>> Objects = new Dictionary<string, List<GameObject>>();
        
        // Регистрируем компоненты
        private void Register()
        {
            this.Components.Clear();
            this.Objects.Clear();
            this.Components.Add("key", "AudioSource"); 
            this.Components.Add("key2", "VRC_Panorama");
            
        }

        // Подготовка
        private void Prepare()
        {
            this.SceneObjects = Resources.FindObjectsOfTypeAll(typeof(GameObject)) as GameObject[];
            this.boxGuiStyle = new GUIStyle();
            this.boxGuiStyle.normal.background = Texture2D.whiteTexture;
            this.boxGuiStyle.normal.textColor = new Color(0.85f, 0.85f, 0.85f);
        }

        [MenuItem ("Loli E1ON/Analyzer Reconstruction")]
        public static void ShowWindow ()
        {
            EditorWindow.GetWindow(typeof(AnalyzerReconstruction));
        }

        public void OnGUI()
        {

            EditorGUILayout.Space();
            if (GUILayout.Button ("Analysis Scene")) AnalyzeScene = !AnalyzeScene;
            EditorGUILayout.Space();

            if (this.ShowInfo) {

                EditorGUILayout.HelpBox ("test", MessageType.Info);
                foreach(KeyValuePair<string, string> component in this.Components) {
                    
                    EditorGUILayout.BeginVertical(boxGuiStyle);
                    EditorGUILayout.LabelField(component.Value, EditorStyles.boldLabel);
                    EditorGUILayout.EndVertical();
                    
                    EditorGUILayout.BeginHorizontal();
                    this.ScrollPosition = EditorGUILayout.BeginScrollView(this.ScrollPosition, GUILayout.Height(100));
                    
                    foreach(KeyValuePair<string, List<GameObject>> storage in this.Objects) {
                        if (storage.Key == component.Key) {
                            //Debug.Log(storage.Value);
                            foreach(GameObject gameObject in storage.Value) {
                                //Debug.Log(gameObject);
                                //EditorGUILayout.LabelField(gameObject.name, EditorStyles.boldLabel, GUILayout.ExpandWidth(false));
                            }
                            
                        }
                    }
                    
                    EditorGUILayout.EndScrollView();
                    EditorGUILayout.EndHorizontal();
                }
            }

            if (AnalyzeScene) {
                this.Prepare();
                this.Register();
                this.Analyze();
                this.ShowInfo = true;
                AnalyzeScene = !AnalyzeScene;
            }
        }

        private void Analyze()
        {
            foreach(KeyValuePair<string, string> component in this.Components) {
                List<GameObject> tempObjects = new List<GameObject>();
                foreach (GameObject gameObject in this.SceneObjects) {
                    if (gameObject.GetComponent(component.Value) != null) {
                        tempObjects.Add(gameObject);
                    }
                }
                this.Objects.Add(component.Key, tempObjects);

                foreach (KeyValuePair<string, List<GameObject>> o in this.Objects)
                {
                    foreach (GameObject gameObject in o.Value)
                    {
                        Debug.Log(gameObject.name);
                        EditorGUILayout.LabelField(gameObject.name, EditorStyles.boldLabel, GUILayout.ExpandWidth(false));
                    }
                }
                

                tempObjects.Clear();
            }
        }
    }
}