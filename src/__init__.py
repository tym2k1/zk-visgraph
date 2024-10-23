#!/usr/bin/env python3

import os
import sys
import json
import gi
import webview
from pyvis.network import Network
from collections import defaultdict

class API:
    def send_label(self, label):
        print(label)  # Print the label to stdout
        sys.stdout.flush() # Ensure the output is flushed immediately
        os._exit(0)

# Initialize the API
api = API()

net = Network()
input_json = sys.stdin.read()
data = json.loads(input_json)

tags_set = set()
degree_count = defaultdict(int)

# Add nodes for each note and track degree for each node
for note in data['notes']:
    net.add_node(note['filenameStem'], title=note['filename'], label=note['title'])
    degree_count[note['filenameStem']] = 0  # Initialize degree count for notes

    for tag in note.get('tags', []):
        if tag not in tags_set:
            net.add_node(tag, label=f"#{tag}", shape='box', color='orange')
            tags_set.add(tag)
        net.add_edge(tag, note['filenameStem'], width=0.5)
        # degree_count[note['filenameStem']] += 1  # Increment degree for note
        degree_count[tag] += 1  # Increment degree for tag

# Add edges for links between notes
for link in data['links']:
    net.add_edge(link['title'], link['sourcePath'].replace('.md', ''))
    degree_count[link['title']] += 1  # Increment degree for source
    degree_count[link['sourcePath'].replace('.md', '')] += 1  # Increment degree for target

# Update node size based on degree count
for node, degree in degree_count.items():
    net.get_node(node)['size'] = 10 + 2*degree  # Base size 10, increase with degree

# net.show_buttons()
# net.set_options("""
#
# """)

# Generate HTML with custom JavaScript for double-click event
net_html = net.generate_html()
custom_js = """
<script type="text/javascript">
    network.on("doubleClick", function (params) {
        if (params.nodes.length > 0) {
            var nodeId = params.nodes[0];
            var node = nodes.get(nodeId);
            // Check if the clicked node is a tag node
            if (node.shape === 'box') {
                console.log("Tag node clicked:", node.label);
                return; // Ignore clicks on tag nodes
            }
            console.log("Node clicked:", node.label);
            // Use webview's evaluate to send the label back to Python
            window.pywebview.api.send_label(node.title);
        }
    });
</script>
"""

# Embed the custom JavaScript in the HTML
net_html = net_html.replace("</body>", custom_js + "</body>")

# Save the modified HTML to a file
with open("net.html", "w") as file:
    file.write(net_html)

webview.create_window('My App', "./net.html", js_api=api)
webview.start()
