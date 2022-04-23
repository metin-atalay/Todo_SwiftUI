//
//  AddTodoView.swift
//  Todo App
//
//  Created by Metin Atalay on 23.04.2022.
//

import SwiftUI

struct AddTodoView: View {
    // MARK: - PROP
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name:String = ""
    @State private var priority:String = ""
    
    let priorities = ["High", "Normal", "Low"]
    
    @State private var errorShowing: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - TODO NAME
                    TextField("Todo", text: $name)
                        .padding()
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(9)
                        .font(.system(size: 24 , weight: .bold, design: .default))
                    
                    // MARK: - TODO PRIORITY
                    
                    Picker("Priority", selection: $priority){
                        ForEach(priorities, id: \.self){
                            Text($0)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    Button {
                        if self.name != "" {
                            let todo = Todo(context: self.viewContext)
                            
                            todo.name = self.name
                            todo.priority = self.priority
                            
                            do {
                                try self.viewContext.save()
                                print("name \(self.name) ** priority \(self.priority)")
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            self.errorShowing = true
                            self.errorTitle = "Invalid Name"
                            self.errorMessage = "Make sure to enter something for\nthe new todo item."
                            
                            return
                        }
                        
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                        .font(.system(size: 24 , weight: .bold, design: .default))
                        .padding()
                        .frame(minWidth:0, maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(9)
                        .foregroundColor(.white)
                       
                    }
                } //: VSTACK
                .padding(.horizontal)
                .padding(.vertical, 30)
                
                Spacer()
                
            }
            .navigationBarTitle("New Todo", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
            })
            )
            .alert(isPresented: $errorShowing) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
            }
        } //: NAVIGATION VIEW
    }
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView()
    }
}
