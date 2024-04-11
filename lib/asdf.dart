
// ignore_for_file: non_constant_identifier_names

                /*child: Card(
                child: Center(
                  child: Column(
                    children: [
                      Hero(
                          tag: 'colorbox:${_subjects[index].name}',
                          child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(Theming.radius - 10)),
                                  gradient: Theming.gradientToDarker(_subjects[index].color)),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      IconButton(
                                          icon: const Icon(Icons.color_lens_rounded),
                                          onPressed: () => editColor(index)),
                                      IconButton(
                                          icon: const Icon(Icons.edit_rounded), onPressed: () => editSubject(index)),
                                      IconButton(
                                          icon: const Icon(Icons.delete_rounded),
                                          onPressed: () => deleteSubject(_subjects[index])),
                                    ],
                                  ),
                                ),
                              ))),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                _subjects[index].name,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              )),
                          Hero(
                              tag: 'icon:${_subjects[index].name}',
                              child:
                                  Align(alignment: Alignment.topRight, child: Icon(_subjects[index].icon, size: 100)))
                        ]),
                      )
                    ],
                  ),
                ),
              ), 



                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.color_lens_rounded),
                                        onPressed: () => editColor(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded),
                                        onPressed: () => editSubject(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_rounded),
                                        onPressed: () => deleteSubject(_subjects[index]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),*/