//
//  ContentView.swift
//  Todo App
//
//  Created by Metin Atalay on 23.04.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Todo.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Todo.name, ascending: true)]) var todos:  FetchedResults<Todo>
    
    
    @EnvironmentObject var iconSettings: IconNames
    
    @State private var showingSettingsView: Bool = false
    @State private var showingAddTodoView: Bool = false
    @State private var animatingButton: Bool = false
    
    // THEME
    @ObservedObject var theme = ThemeSettings.shared
    var themes: [Theme] = themeData
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(self.todos, id: \.self) { todo in
                        
                        HStack {
                          Circle()
                            .frame(width: 12, height: 12, alignment: .center)
                            .foregroundColor(self.colorize(priority: todo.priority ?? "Normal"))
                          Text(todo.name ?? "Unknown")
                            .fontWeight(.semibold)
                          
                          Spacer()
                          
                          Text(todo.priority ?? "Unkown")
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.systemGray2))
                            .padding(3)
                            .frame(minWidth: 62)
                            .overlay(
                              Capsule().stroke(Color(UIColor.systemGray2), lineWidth: 0.75)
                          )
                        } //: HSTACK
                        
                    } //: FOR
                    
                    .onDelete(perform: deleteTodo)
                } //: LIST
                .navigationBarTitle("Todo", displayMode: .inline)
                .navigationBarItems(
                    leading: EditButton()
                    ,trailing:
                        Button(action: {
                            self.showingSettingsView.toggle()
                        }, label: {
                            Image(systemName: "paintbrush")
                                .imageScale(.large)
                        })
                        .sheet(isPresented: $showingSettingsView, content: {
                            SettingsView().environmentObject(self.iconSettings)
                        })
                )
                .sheet(isPresented: $showingAddTodoView) {
                    AddTodoView().environment(\.managedObjectContext, self.viewContext)
                }
                
                if todos.count == 0 {
                    EmptyListView()
                }
                
            } //: ZSTACK
            .sheet(isPresented: $showingAddTodoView) {
                AddTodoView().environment(\.managedObjectContext, self.viewContext)
            }
            .overlay(
                ZStack {
                  Group {
                    Circle()
                      .fill(themes[self.theme.themeSettings].themeColor)
                      .opacity(self.animatingButton ? 0.2 : 0)
                      .scaleEffect(self.animatingButton ? 1 : 0)
                      .frame(width: 68, height: 68, alignment: .center)
                    Circle()
                      .fill(themes[self.theme.themeSettings].themeColor)
                      .opacity(self.animatingButton ? 0.15 : 0)
                      .scaleEffect(self.animatingButton ? 1 : 0)
                      .frame(width: 88, height: 88, alignment: .center)
                  }
                  //.animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true))
                  
                  Button(action: {
                    self.showingAddTodoView.toggle()
                  }) {
                    Image(systemName: "plus.circle.fill")
                      .resizable()
                      .scaledToFit()
                      .background(Circle().fill(Color("ColorBase")))
                      .frame(width: 48, height: 48, alignment: .center)
                  } //: BUTTON
                    .accentColor(themes[self.theme.themeSettings].themeColor)
                    .onAppear(perform: {
                       self.animatingButton.toggle()
                    })
                } //: ZSTACK
                  .padding(.bottom, 15)
                  .padding(.trailing, 15)
                  , alignment: .bottomTrailing
              )
        }
    }
    
    // MARK: - FUNC
    
    private func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            let todo = todos [index]
            viewContext.delete(todo)
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func colorize(priority: String) -> Color {
      switch priority {
      case "High":
        return .pink
      case "Normal":
        return .green
      case "Low":
        return .blue
      default:
        return .gray
      }
    }
    
}


struct ContentViewProvider_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
         
         ContentView().environment(\.managedObjectContext, context)
        
       // ContentView()
    }
}
