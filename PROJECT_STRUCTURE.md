# Image Editor Project Structure

## Overview
This Flutter application provides a simple frontend for image editing using AI models. The app allows users to drag and drop images, enter editing instructions, select from available AI processors, and process images.

## Project Structure

```
lib/
├── domain/
│   ├── model/
│   │   ├── image_model.dart          # Image data model
│   │   └── image_processor.dart      # Available AI processors model
│   └── repository/                   # Repository interfaces (future use)
├── data/
│   ├── dto/                          # Data transfer objects (future use)
│   └── repository/                   # Repository implementations (future use)
├── presentation/
│   ├── screen/
│   │   └── image_editor_screen.dart  # Main image editor screen
│   ├── widget/
│   │   ├── image_drop_box.dart       # Drag & drop image widget
│   │   ├── instruction_text_field.dart # Text input for instructions
│   │   └── processor_dropdown.dart   # AI processor selection dropdown
│   ├── navigation/
│   │   └── app_router.dart           # Go router configuration
│   ├── bloc/                         # State management (future use)
│   └── theme/                        # App theming (future use)
└── main.dart                         # App entry point
```

## Features

### Current Implementation
- **Dual Image Display**: Side-by-side input and output image boxes
- **Drag & Drop Support**: Users can drag images into the input box or click to select
- **Text Instructions**: Multi-line text field for editing instructions
- **Processor Selection**: Dropdown with available AI models (currently qwen-image-edit)
- **Process Button**: Validates inputs and simulates processing
- **Progress Indicators**: Shows processing state with loading indicators

### Key Components

#### ImageDropBox
- Handles image selection via file picker or drag & drop
- Displays selected images with remove functionality
- Shows loading state during processing
- Responsive design with dotted border styling

#### ProcessorDropdown
- Lists available AI image processors
- Shows processor name and description
- Uses FormField for validation integration

#### InstructionTextField
- Multi-line text input for editing instructions
- Real-time validation and character limits support

#### ImageEditorScreen
- Main screen coordinating all components
- Handles state management for the editing process
- Validates inputs before processing
- Shows success/error feedback via snackbars

## Dependencies
- `go_router`: Navigation and routing
- `dotted_border`: Styling for drag & drop areas
- `file_picker`: File selection functionality

## Next Steps
- Integrate with Serverpod backend
- Implement actual AI model communication
- Add more image processors
- Enhance error handling and validation
- Add image preview and editing tools
