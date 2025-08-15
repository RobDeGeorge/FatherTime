# Responsive Popup Menu System

A comprehensive QML popup menu system designed for modern applications with full responsive behavior, accessibility support, and Microsoft Fluent Design principles.

## 🎯 Key Features

### ✅ **Always Anchored & Contained**
- Uses QML's `Overlay` system for proper z-ordering
- `anchors.centerIn: Overlay.overlay` ensures menus never render outside visible area
- Automatic repositioning on window resize
- Respects parent boundaries with mathematical constraints

### ✅ **Fully Responsive Sizing**
- Proportional dimensions: `width: parent.width * 0.4` with min/max constraints
- Aspect ratio preservation for all visual elements
- Screen-size-aware scaling factors
- Typography scales with screen dimensions

### ✅ **Preserved Aspect Ratios**
- Images use `fillMode: Image.PreserveAspectFit`
- All containers use QML layouts (`ColumnLayout`, `RowLayout`)
- Proportional `Layout.preferredWidth` and `Layout.preferredHeight`
- No hardcoded dimensions except minimums

### ✅ **Modern Design Standards**
- Microsoft Fluent Design typography (`Segoe UI, system-ui`)
- Clean visual hierarchy with proper contrast ratios
- Rounded corners with proportional radius
- Smooth animations following design guidelines
- Elevation shadows for depth perception

### ✅ **Production-Ready**
- Comprehensive keyboard navigation (Arrow keys, Enter, Escape)
- Full accessibility support with `Accessible` properties
- Thorough documentation and comments
- Error handling and edge cases covered
- Performance optimized with efficient layouts

## 📐 Responsive Design Architecture

### Sizing Strategy
```qml
// Base dimensions with constraints
readonly property real baseWidth: Math.min(Math.max(parent.width * 0.4, 280), 480)
readonly property real baseHeight: Math.min(parent.height * 0.6, baseWidth * 1.2)

// Proportional scaling
readonly property real scaleFactor: Math.min(parent.width / 1200, parent.height / 800)
readonly property real spacing: Math.max(baseWidth * 0.02, 8)
readonly property real padding: Math.max(baseWidth * 0.04, 16)
```

### Typography Scaling
```qml
// Headers
font.pixelSize: Math.max(root.baseWidth * 0.04, 18)

// Body text
font.pixelSize: Math.max(root.baseWidth * 0.035, 14)

// Caption text
font.pixelSize: Math.max(root.baseWidth * 0.025, 12)
```

### Layout Proportions
```qml
// Icon sizing
Layout.preferredWidth: Math.max(root.baseWidth * 0.08, 32)
Layout.preferredHeight: Layout.preferredWidth

// Item heights
height: Math.max(root.baseWidth * 0.12, 48)

// Spacing between elements
spacing: Math.max(root.baseWidth * 0.02, 8)
```

## 🎨 Visual Design System

### Color Palette (Fluent Design)
- **Background**: `#F9F9F9` (Light neutral)
- **Border**: `#E0E0E0` (Subtle boundaries)
- **Text Primary**: `#1F1F1F` (High contrast)
- **Text Secondary**: `#666666` (Medium contrast)
- **Hover State**: `#F5F5F5` (Subtle highlight)
- **Pressed State**: `#E0E0E0` (Clear feedback)

### Elevation & Shadows
```qml
layer.effect: DropShadow {
    horizontalOffset: 0
    verticalOffset: Math.max(root.baseWidth * 0.01, 4)
    radius: Math.max(root.baseWidth * 0.03, 16)
    samples: 17
    color: "#20000000"
    transparentBorder: true
}
```

### Animations
- **Enter**: 200ms OutCubic with opacity + scale
- **Exit**: 150ms InCubic with opacity + scale
- **Interactions**: 100-150ms smooth transitions

## 🔧 Usage Examples

### Basic Menu
```qml
ResponsivePopupMenu {
    id: fileMenu
    menuTitle: "File"
    iconSource: "file-icon.png"
    menuItems: [
        { title: "New", icon: "new.png", trailing: "Ctrl+N" },
        { title: "Open", icon: "open.png", trailing: "Ctrl+O" },
        { title: "Save", icon: "save.png", trailing: "Ctrl+S" }
    ]
    
    onItemSelected: function(index, item) {
        console.log("Selected:", item.title)
        // Handle menu selection
    }
}

// Open the menu
Button {
    text: "File"
    onClicked: fileMenu.openMenu()
}
```

### Advanced Menu with Subtitles
```qml
ResponsivePopupMenu {
    menuTitle: "Settings"
    menuItems: [
        {
            title: "Privacy & Security",
            subtitle: "Control your privacy settings and security options",
            icon: "security.png"
        },
        {
            title: "Notifications",
            subtitle: "Configure how and when you receive notifications",
            icon: "notifications.png"
        }
    ]
}
```

### Dynamic Content
```qml
ResponsivePopupMenu {
    id: dynamicMenu
    
    function updateContent() {
        var items = []
        // Generate items dynamically
        for (var i = 0; i < dataModel.count; i++) {
            items.push({
                title: dataModel.get(i).name,
                subtitle: dataModel.get(i).description,
                icon: dataModel.get(i).iconPath
            })
        }
        menuItems = items
    }
}
```

## 📱 Responsive Breakpoints

| Screen Size | Base Width | Scaling | Typography |
|-------------|------------|---------|------------|
| Mobile (≤480px) | 280px min | 0.6x min | 14px min |
| Tablet (481-1024px) | 30-40% width | 0.7-0.9x | 16-20px |
| Desktop (≥1025px) | 480px max | 1.0x | 18-24px |

## ⌨️ Keyboard Navigation

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate menu items |
| `Enter` / `Return` | Select current item |
| `Escape` | Close menu |
| `Tab` | Focus navigation (accessibility) |

## ♿ Accessibility Features

- **Screen Reader Support**: Full `Accessible` property implementation
- **Keyboard Navigation**: Complete keyboard-only operation
- **High Contrast**: WCAG AA compliant color ratios
- **Focus Management**: Clear focus indicators and logical order
- **Semantic Roles**: Proper ARIA roles for assistive technologies

## 🧪 Testing Scenarios

### Screen Size Testing
1. **Mobile Portrait**: 360×640px
2. **Mobile Landscape**: 640×360px
3. **Tablet Portrait**: 768×1024px
4. **Tablet Landscape**: 1024×768px
5. **Desktop Small**: 1200×800px
6. **Desktop Large**: 1920×1080px

### Content Variations
- **Short items**: 3-5 items with simple text
- **Long items**: 10+ items with scrolling
- **Complex items**: Items with icons, subtitles, and trailing elements
- **Dynamic content**: Runtime content updates
- **Empty states**: Graceful handling of no items

### Edge Cases
- **Very long text**: Proper ellipsis and wrapping
- **Missing icons**: Graceful degradation
- **Rapid interactions**: Smooth animation queueing
- **Window resizing**: Maintain positioning and proportions

## 🔧 Customization Options

### Styling Properties
```qml
// Colors
property color backgroundColor: "#F9F9F9"
property color borderColor: "#E0E0E0"
property color textColor: "#1F1F1F"
property color textSecondaryColor: "#666666"

// Sizing
property real maxWidth: 480
property real minWidth: 280
property real widthRatio: 0.4

// Typography
property string fontFamily: "Segoe UI, system-ui, sans-serif"
property int headerSize: 18
property int bodySize: 14
```

### Behavioral Options
```qml
// Interaction
property bool showCloseButton: true
property bool keyNavigationEnabled: true
property bool autoClose: true

// Animation
property int enterDuration: 200
property int exitDuration: 150
property string enterEasing: "OutCubic"
```

## 🚀 Performance Considerations

- **Efficient Layouts**: Uses QML's optimized layout system
- **Lazy Loading**: Content loaded only when needed
- **Animation Optimization**: Hardware-accelerated transforms
- **Memory Management**: Proper component lifecycle
- **Rendering Efficiency**: Minimized overdraw and repaints

## 📦 File Structure
```
ui/components/
├── ResponsivePopupMenu.qml     # Main component
├── PopupMenuDemo.qml          # Demo application
└── README_PopupMenuSystem.md  # This documentation
```

## 🔄 Version History

- **v1.0**: Initial implementation with full responsive design
- Complete Fluent Design compliance
- Full accessibility support
- Comprehensive testing and documentation

---

*This popup menu system is production-ready and follows modern QML best practices for maintainable, scalable UI components.*