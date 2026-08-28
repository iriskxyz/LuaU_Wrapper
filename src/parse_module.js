const fs = require('fs');
const { RobloxFile } = require("rbxm-parser");

async function convertRbxmToJson(inputPath, outputPath) {
    try {
        const buffer = fs.readFileSync(inputPath);
        const parsed = await RobloxFile.ReadFromBuffer(buffer);
        
        const mainModule = parsed.FindFirstChildOfClass("ModuleScript");
        if (!mainModule) throw new Error("No ModuleScript found at root.");

        function serializeInstance(instance) {
            const data = {
                ClassName: instance.ClassName,
                Name: instance.Name,
                Properties: {},
                Children: []
            };

            if (instance.Source !== undefined) data.Properties.Source = instance.Source;
            if (instance.Value !== undefined) data.Properties.Value = instance.Value;
            if (instance.Disabled !== undefined) data.Properties.Disabled = instance.Disabled;
            if (instance.Text !== undefined) data.Properties.Text = instance.Text;

            for (const child of instance.GetChildren()) {
                data.Children.push(serializeInstance(child));
            }

            return data;
        }

        const treeJson = serializeInstance(mainModule);
        fs.writeFileSync(outputPath, JSON.stringify(treeJson, null, 2));
        console.log("Successfully exported to", outputPath);
        return true;

    } catch (err) {
        console.error("Parse failed:", err);
        return false;
    }
}

const [,, input, output] = process.argv;
convertRbxmToJson(input, output);