/*
Copyright 2022 Esri
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.​
*/

using ArcGIS.Desktop.Metadata.Editors.ClassicEditor;
using ArcGIS.Desktop.Metadata.Editors.ClassicEditor.Pages;

namespace upgrade_blank.Pages
{
  internal class ReferenceSystemSidebarLabel : ISidebarLabel
  {
    string ISidebarLabel.SidebarLabel
    {
      get { return ReferenceSystemSidebarLabel.SidebarLabel; }
    }

    public static string SidebarLabel
    {
      get { return upgrade_blank.Properties.Resources.CFG_LBL_REFERENCESYSTEM; }
    }
  }
  /// <summary>
  /// Interaction logic for MTK_ReferenceSystem.xaml
  /// </summary>
  internal partial class MTK_ReferenceSystem : EditorPage
  {
    public MTK_ReferenceSystem()
    {
      InitializeComponent();
    }

    public override string SidebarLabel
    {
      get { return ReferenceSystemSidebarLabel.SidebarLabel; }
    }
  }
}
