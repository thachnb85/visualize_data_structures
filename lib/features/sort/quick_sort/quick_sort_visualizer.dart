import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visualize_data_structures/core/themes/themes.dart';
import 'package:visualize_data_structures/core/widgets/node_widget.dart';

import 'quick_sort_provider.dart';

class QuickSortVisualizer extends StatefulWidget {
  @override
  _QuickSortVisualizerState createState() => _QuickSortVisualizerState();
}

class _QuickSortVisualizerState extends State<QuickSortVisualizer>
    with SingleTickerProviderStateMixin {
  QuickSortProvider provider;
  double nodeSize = 30.0;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reset();
          provider.isSwapping = false;
          provider.matchArrays();
          provider.stepForward();
          provider.notify();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<QuickSortProvider>(context);
    return Center(
      child: Selector<QuickSortProvider, List<int>>(
        selector: (_, provider) => provider.array,
        builder: (_, list, __) => _buildArrayNodes(),
      ),
    );
  }

  Widget _buildArrayNodes() {
    bool shouldSwap = provider.isSwapState &&
        !animationController.isAnimating &&
        !provider.isCompleted;

    if (shouldSwap) {
      provider.isSwapping = true;
      animationController.forward();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        provider.state == QuickSortState.swap
            ? _buildAnimatedNodes()
            : _buildNodes(),
        _buildIndexes(),
        _buildIJ(),
      ],
    );
  }

  Widget _buildNodes() {
    List<int> list = provider.array;
    List<Widget> children = [];
    for (int i = 0; i < list.length; i++) {
      children.add(
        Positioned(
          left: i * (nodeSize + 1),
          top: nodeSize * 2,
          child: NodeWidget<int>(
            data: list[i],
            color: skyBlue,
          ),
        ),
      );
    }
    return Container(
      width: nodeSize * list.length + list.length,
      height: nodeSize * 3,
      child: Stack(
        children: children,
      ),
    );
  }

  double _getTop(Set<int> set, int index) {
    double defaultValue = nodeSize * 2;
    if (set.contains(index)) {
      if (animationController.value < 1 / 3) {
        return Tween<double>(
          begin: defaultValue,
          end: 0,
        )
            .animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval(0, 0.33),
              ),
            )
            .value;
      } else if (animationController.value > 2 * (1 / 3)) {
        return Tween<double>(
          begin: 0,
          end: defaultValue,
        )
            .animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval(0.66, 1),
              ),
            )
            .value;
      } else {
        return 0;
      }
    }
    return defaultValue;
  }

  double _getLeft(Set<int> set, int index) {
    double defaultValue = index * (nodeSize + 1);
    if (set.isEmpty) return defaultValue;

    int minIndex = Math.min(set.first, set.last);
    int maxIndex = Math.max(set.first, set.last);
    if (index == minIndex) {
      return Tween<double>(
        begin: defaultValue,
        end: defaultValue + (maxIndex - minIndex) * (nodeSize + 1),
      )
          .animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(0.33, 0.66),
            ),
          )
          .value;
    } else if (index == maxIndex) {
      return Tween<double>(
        begin: defaultValue,
        end: defaultValue + (minIndex - maxIndex) * (nodeSize + 1),
      )
          .animate(
            CurvedAnimation(
              parent: animationController,
              curve: Interval(0.33, 0.66),
            ),
          )
          .value;
    }
    return defaultValue;
  }

  Widget _buildAnimatedNodes() {
    List<int> list = provider.oldArray;
    Set<int> set = provider.changedIndexes();
    List<Widget> children = [];
    for (int i = 0; i < list.length; i++) {
      children.add(
        Positioned(
          left: _getLeft(set, i),
          top: _getTop(set, i),
          child: NodeWidget<int>(
            data: list[i],
            color: skyBlue,
          ),
        ),
      );
    }
    return Container(
      width: nodeSize * list.length + list.length,
      height: nodeSize * 3,
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _buildIndexes() {
    int size = provider.array.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < size; i++) NodeWidget<int>(data: i)
      ],
    );
  }

  Widget _buildIJ() {
    int size = provider.array.length;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < size; i++) NodeWidget<String>(data: _getIJText(i))
      ],
    );
  }

  String _getIJText(index) {
    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.pivotIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'lipjr';

    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.pivotIndex == index &&
        provider.jIndex == index) return 'lipj';

    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.pivotIndex == index &&
        provider.rightIndex == index) return 'lipr';

    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'lijr';

    if (provider.leftIndex == index &&
        provider.pivotIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'lpjr';

    if (provider.iIndex == index &&
        provider.pivotIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'ipjr';

    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.pivotIndex == index) return 'lip';

    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.jIndex == index) return 'lij';

    if (provider.leftIndex == index &&
        provider.iIndex == index &&
        provider.rightIndex == index) return 'lir';

    if (provider.leftIndex == index &&
        provider.pivotIndex == index &&
        provider.jIndex == index) return 'lpj';

    if (provider.leftIndex == index &&
        provider.pivotIndex == index &&
        provider.rightIndex == index) return 'lpr';

    if (provider.leftIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'ljr';

    if (provider.iIndex == index &&
        provider.pivotIndex == index &&
        provider.jIndex == index) return 'ipj';

    if (provider.iIndex == index &&
        provider.pivotIndex == index &&
        provider.rightIndex == index) return 'ipr';

    if (provider.iIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'ijr';

    if (provider.pivotIndex == index &&
        provider.jIndex == index &&
        provider.rightIndex == index) return 'pjr';

    if (provider.leftIndex == index && provider.iIndex == index) return 'l i';
    if (provider.leftIndex == index && provider.jIndex == index) return 'l j';
    if (provider.leftIndex == index && provider.pivotIndex == index)
      return 'l p';
    if (provider.iIndex == index && provider.pivotIndex == index) return 'i p';
    if (provider.iIndex == index && provider.jIndex == index) return 'i j';
    if (provider.iIndex == index && provider.rightIndex == index) return 'i r';
    if (provider.pivotIndex == index && provider.jIndex == index) return 'p j';
    if (provider.pivotIndex == index && provider.rightIndex == index)
      return 'p r';
    if (provider.jIndex == index && provider.rightIndex == index) return 'j r';

    if (provider.pivotIndex == index) return 'p';
    if (provider.leftIndex == index) return 'l';
    if (provider.rightIndex == index) return 'r';
    if (provider.iIndex == index) return 'i';
    if (provider.jIndex == index) return 'j';

    return '';
  }
}
