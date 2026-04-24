import SwiftUI

struct AddWidgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = 0
    
    let onAdd: (AppWidgetFamily) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Picker
                        Picker("Category", selection: $selectedCategory) {
                            Text("Home Screen").tag(0)
                            Text("Lock Screen").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        if selectedCategory == 0 {
                            homeScreenOptions
                        } else {
                            lockScreenOptions
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var homeScreenOptions: some View {
        VStack(spacing: 16) {
            Text("HOME SCREEN")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            widgetOption(.homeSmall, icon: "square", title: "Small", subtitle: "1×1 grid • 1 icon", preview: "⬜")
            
            widgetOption(.homeMedium, icon: "square.grid.3x3", title: "Medium", subtitle: "3×3 grid • 9 icons", preview: "⬜⬜⬜\n⬜⬜⬜\n⬜⬜⬜")
            
            widgetOption(.homeLarge, icon: "rectangle.grid.2x3", title: "Large", subtitle: "6×3 grid • 18 icons", preview: "⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜")
            
            widgetOption(.homeExtraLarge, icon: "rectangle.grid.3x2", title: "Extra Large", subtitle: "6×6 grid • 36 icons", preview: "⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜\n⬜⬜⬜⬜⬜⬜")
        }
    }
    
    private var lockScreenOptions: some View {
        VStack(spacing: 16) {
            Text("LOCK SCREEN")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            widgetOption(.lockCircular, icon: "circle", title: "Circular", subtitle: "1 icon", preview: "⭕")
            
            widgetOption(.lockRectangular, icon: "rectangle", title: "Rectangular", subtitle: "Up to 6 items", preview: "⭕ ⭕ ⭕\n⭕ ⭕ ⭕")
            
            widgetOption(.lockInline, icon: "text.alignleft", title: "Inline", subtitle: "Single line text", preview: "━━━━━━━━━━━━")
        }
    }
    
    private func widgetOption(_ family: AppWidgetFamily, icon: String, title: String, subtitle: String, preview: String) -> some View {
        Button {
            onAdd(family)
            dismiss()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Spacer()
                
                Text(preview)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
                
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    AddWidgetSheet { _ in }
}