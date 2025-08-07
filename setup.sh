#!/bin/bash

# Setup script for GiftCard8Assessment iOS News App
# This script helps new users get started quickly

echo "🚀 Setting up GiftCard8Assessment iOS News App"
echo "=============================================="
echo ""

# Check if Secrets.swift already exists
if [ -f "GiftCard8Assessment/Config/Secrets.swift" ]; then
    echo "✅ Secrets.swift already exists"
else
    echo "📝 Creating Secrets.swift from template..."
    cp "GiftCard8Assessment/Config/Secrets.swift.template" "GiftCard8Assessment/Config/Secrets.swift"
    echo "✅ Secrets.swift created"
fi

echo ""
echo "🔑 Next Steps:"
echo "1. Get your free GNews API key:"
echo "   → Visit: https://gnews.io/"
echo "   → Sign up for a free account"
echo "   → Copy your API key"
echo ""
echo "2. Add your API key:"
echo "   → Open: GiftCard8Assessment/Config/Secrets.swift"
echo "   → Replace 'YOUR_GNEWS_API_KEY_HERE' with your actual API key"
echo ""
echo "3. Open the project:"
echo "   → Run: open GiftCard8Assessment.xcodeproj"
echo ""
echo "4. Build and run the app in Xcode (Cmd+R)"
echo ""
echo "📚 For detailed instructions, see README.md"
echo ""
echo "⚠️  Remember: Never commit your actual API keys to version control!"
echo ""

# Check if Xcode is available
if command -v xcode-select &> /dev/null; then
    echo "✅ Xcode is installed"
    
    # Ask if user wants to open the project
    read -p "🤔 Would you like to open the project in Xcode now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Opening project in Xcode..."
        open GiftCard8Assessment.xcodeproj
    fi
else
    echo "❌ Xcode not found. Please install Xcode from the App Store."
fi

echo ""
echo "🎉 Setup complete! Happy coding!"