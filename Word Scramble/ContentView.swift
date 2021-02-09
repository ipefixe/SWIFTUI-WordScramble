//
//  ContentView.swift
//  Word Scramble
//
//  Created by Kevin Boulala on 02/02/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var score = 0
    
    @State private var titleError = ""
    @State private var messageError = ""
    @State private var showingError = false
        
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .autocapitalization(.none)
                    .padding()
                
                HStack(alignment: .center) {
                    Spacer()
                    Text("Your score is \(score)")
                        .fontWeight(.heavy)
                    Spacer()
                }
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                        .frame(maxWidth: .infinity)

                }
            }
            .navigationBarTitle("\(rootWord)")
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(titleError), message: Text(messageError), dismissButton: .default(Text("OK")))
            })
            .navigationBarItems(trailing: Button("New game", action: startGame))
        }
    }
    
    func startGame() {
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                let words = fileContents.components(separatedBy: "\n")
                rootWord = words.randomElement() ?? "something"
                usedWords = []
                score = 0
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !answer.isEmpty else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Already used", message: "Find another word!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not possible", message: "That isn't a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        
        score = usedWords.reduce(0) { (score, element) -> Int in
            score + element.count
        }
        
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) && word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        titleError = title
        messageError = message
        showingError = true
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
