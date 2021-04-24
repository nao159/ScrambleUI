//
//  ContentView.swift
//  ScrambleUI
//
//  Created by Максим Нуждин on 24.04.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("input your word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding(.leading)
                    .padding(.trailing)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: {
                startGame()
            })
            .alert(isPresented: $showingAlert) { () -> Alert in
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("ok")))
            }
        }
    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        guard isOriginal(word: answer) else {
            wordError(title: "word already exists", message: "be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "wrong word", message: "type the currect word, some of letters doesnt exist in '\(rootWord)'")
            return
        }
        guard isRealWord(word: answer) else {
            wordError(title: "wrong word", message: "this word doesnt exist in the real word")
            return
        }
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let wordListURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let wordList = try? String(contentsOf: wordListURL) {
                let words = wordList.components(separatedBy: "\n")
                rootWord = words.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not find start.txt file")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isRealWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





