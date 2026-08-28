const fs = require('fs');
const { RobloxFile } = require("rbxm-parser");

async function convertRbxmToJson(inputPath, outputPath) {
    try {
        const buffer = fs.readFileSync(inputPath);
        const parsed = await RobloxFile.ReadFromBuffer(buffer);
        
        let mainModule = parsed.FindFirstChildOfClass("ModuleScript");
        
        if (!mainModule) {
            mainModule = parsed.FindFirstDescendantOfClass("ModuleScript");
        }
        
        if (!mainModule) {
            throw new Error("No ModuleScript could be found anywhere in this asset.");
        }

        function serializeInstance(instance) {
            const data = {
                ClassName: instance.ClassName,
                Name: instance.Name,
                Properties: {},
                Children: []
            };

            // Extract specific properties
            if (instance.Source !== undefined) data.Properties.Source = instance.Source;
            if (instance.Value !== undefined) data.Properties.Value = instance.Value;
            if (instance.Disabled !== undefined) data.Properties.Disabled = instance.Disabled;
            if (instance.Text !== undefined) data.Properties.Text = instance.Text;

            // FIX: Access the Children array property directly
            const children = instance.Children || [];
            for (const child of children) {
                data.Children.push(serializeInstance(child));
            }

            return data;
        }

        const treeJson = serializeInstance(mainModule);
        fs.writeFileSync(outputPath, JSON.stringify(treeJson, null, 2));
        
        process.exit(0);

    } catch (err) {
        console.error("NODE PARSE ERROR:", err.message);
        process.exit(1); 
    }
}

const [,, input, output] = process.argv;
convertRbxmToJson(input, output);