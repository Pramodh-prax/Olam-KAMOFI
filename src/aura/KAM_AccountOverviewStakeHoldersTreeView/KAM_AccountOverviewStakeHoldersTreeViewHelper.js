({
    createTree: function (component, listItems) {
        let reportsToMap = {};
        let roots = [];

        listItems.forEach((item, index) => {
            reportsToMap[item.Id] = index;
            listItems[index].children = [];
        })

        for (let index = 0; index < listItems.length; index++) {
            let node = listItems[index];
            if (node.ReportsToId && typeof reportsToMap[node.ReportsToId] !== 'undefined') {
                listItems[reportsToMap[node.ReportsToId]].children.push(node);
            } else {
                roots.push(node);
            }
        }

        return roots;
    },
    createContactCard : function (component, contact) {
        let contactCardDiv = document.createElement("div");
        contactCardDiv.classList.add("contact-card-outer-container");

        let imgTag = document.createElement("img");
        imgTag.src = this.getAvatar (contact.Name);
        //imgTag.src = 'https://ui-avatars.com/api/?background=random&size=50&name='+contact.Name;
        imgTag.classList.add ('contact-img');
        contactCardDiv.appendChild (imgTag);

        let infoContainer = document.createElement("div");
        infoContainer.classList.add("contact-card-container");

        let nameTag = document.createElement("span");
        nameTag.innerText = contact.Name;
        nameTag.classList.add ('contact-name');
        infoContainer.appendChild (nameTag);

        let titleTag = document.createElement("span");
        titleTag.innerText = contact.Title ? contact.Title : '-';
        titleTag.classList.add ('desc-text');
        infoContainer.appendChild (titleTag);

        let emailTag = document.createElement("span");
        emailTag.innerText = contact.Email;
        emailTag.classList.add ('desc-text');

        infoContainer.appendChild (emailTag);
        contactCardDiv.appendChild (infoContainer);

        let contactCardOuterDiv = document.createElement("div");
        contactCardOuterDiv.classList.add("contact-card");
        contactCardOuterDiv.appendChild (contactCardDiv);

        contactCardDiv

        return contactCardOuterDiv;
    },
    renderList: function (component, parentNode, node) {
        let newListItem = document.createElement("li");
        let contactCard = this.createContactCard (component, parentNode);
        // if (parentNode) {
        //     spanItem.innerText = parentNode.FirstName;
        // } else {
        //     spanItem.innerText = 'E';
        // }
        newListItem.appendChild(contactCard);
        let self = this;
        if (parentNode && parentNode.children && parentNode.children.length > 0) {

            let newSubList = document.createElement("ul");

            newListItem.appendChild(newSubList);

            parentNode.children.forEach(ele => {
                self.renderList(component, ele, newSubList);
            })
        }

        if (node) {
            node.appendChild(newListItem);
        }
        return newListItem;
    },
    appendToDom: function (component, items) {
        let idAttr = component.get('v.idAttr');
        if (Array.isArray(items)) {
            if (items.length == 0)  {
                $('#' + idAttr + '-tree-list').append(this.createEmptyCard (component));
            }
            for (var i = 0; i < items.length; ++i) {
                $('#' + idAttr + '-tree-list').append(items[i]);
            }
        } else {
            $('#' + idAttr + '-tree-list').append(items);
        }
    },
    createEmptyCard : function (component) {
        let newListItem = document.createElement("li");

        let contactCard = this.createContactCard (component, {
            Name : 'No Contacts found',
            Title : 'Mr.',
            Email : 'nocontacts@olam.com'
        });

        newListItem.appendChild(contactCard);

        return newListItem;
    }
})