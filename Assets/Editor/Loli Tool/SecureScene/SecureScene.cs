using UnityEngine;
using UnityEngine.SceneManagement;

using UnityEditor;
using System.Collections;

public class SecureScene : EditorWindow {

	// Состояние клика
	bool clickStatus = false;
 
	// Активная сцена
	Scene activeScene;

	// Добавляем пункт в меню
    [MenuItem ("Loli Tool/Secure Scene")]

    public static void  ShowWindow () {
        EditorWindow.GetWindow(typeof(SecureScene));
    }

    void OnGUI () {

		// Получаем активную сцену
		this.getActiveScene ();

		// GUI
		EditorGUILayout.LabelField ("Secure Scene");
		EditorGUILayout.HelpBox ("Active Scene: " + activeScene.name, MessageType.Info);
		if (GUILayout.Button ("Перемешать все к хуям")) clickStatus = !clickStatus;

		// Если кнопка нажата
    	if (clickStatus == true) {

			// Вызываем метод
			this.secureCurrentScene ();

			// Сбрасываем нажатие кнопки
			clickStatus = !clickStatus;

    	}

    }

	// Перемешываем всё к хуям
	void secureCurrentScene () {

		const string glyphs= "abcdefghijklmnopqrstuvwxyz0123456789";
		int charAmount = Random.Range(13, 17);
		int rand;

		foreach (GameObject go in UnityEngine.Object.FindObjectsOfType<GameObject>())  {

			if (go.hideFlags == HideFlags.NotEditable || go.hideFlags == HideFlags.HideAndDontSave)
				continue;

			go.name = "loli_";
			for(int i=0; i<charAmount; i++){
				go.name += glyphs[Random.Range(0, glyphs.Length)];
			}

			rand = Random.Range(1, 3);
			Debug.Log(rand);
			if (rand == 2) {
				go.GetComponent<Transform>().SetAsFirstSibling();
			}


		}

	}

	// Получаем активную сцену
	void getActiveScene () {

		this.activeScene = SceneManager.GetActiveScene();

	}
	
}
